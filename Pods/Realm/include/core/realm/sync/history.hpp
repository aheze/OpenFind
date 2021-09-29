
#include <cstdint>
#include <memory>
#include <chrono>
#include <string>

#include <realm/util/string_view.hpp>
#include <realm/impl/cont_transact_hist.hpp>
#include <realm/sync/config.hpp>
#include <realm/sync/instruction_replication.hpp>
#include <realm/sync/protocol.hpp>
#include <realm/sync/transform.hpp>
#include <realm/sync/object_id.hpp>
#include <realm/sync/instructions.hpp>

#ifndef REALM_SYNC_HISTORY_HPP
#define REALM_SYNC_HISTORY_HPP


namespace realm {
namespace _impl {

struct ObjectIDHistoryState;

} // namespace _impl
} // namespace realm


namespace realm {
namespace sync {

struct VersionInfo {
    /// Realm snapshot version.
    version_type realm_version = 0;

    /// The synchronization version corresponding to `realm_version`.
    ///
    /// In the context of the client-side history type `sync_version.version`
    /// will currently always be equal to `realm_version` and
    /// `sync_version.salt` will always be zero.
    SaltedVersion sync_version = {0, 0};
};

timestamp_type generate_changeset_timestamp() noexcept;

// FIXME: in C++17, switch to using std::timespec in place of last two
// arguments.
void map_changeset_timestamp(timestamp_type, std::time_t& seconds_since_epoch, long& nanoseconds) noexcept;

class ClientReplicationBase : public SyncReplication {
public:
    using SyncTransactCallback = void(VersionID old_version, VersionID new_version);

    /// Get the version of the latest snapshot of the associated Realm, as well
    /// as the client file identifier and the synchronization progress as they
    /// are stored in that snapshot.
    ///
    /// The returned current client version is the version produced by the last
    /// changeset in the history. The type of version returned here, is the one
    /// that identifies an entry in the sync history. Whether this is the same
    /// as the snapshot number of the Realm file depends on the history
    /// implementation.
    ///
    /// The returned client file identifier is the one that was last stored by
    /// set_client_file_ident(), or `SaltedFileIdent{0, 0}` if
    /// set_client_file_ident() has never been called.
    ///
    /// The returned SyncProgress is the one that was last stored by
    /// set_sync_progress(), or `SyncProgress{}` if set_sync_progress() has
    /// never been called.
    virtual void get_status(version_type& current_client_version, SaltedFileIdent& client_file_ident,
                            SyncProgress& progress) const = 0;

    /// Stores the server assigned client file identifier in the associated
    /// Realm file, such that it is available via get_status() during future
    /// synchronization sessions. It is an error to set this identifier more
    /// than once per Realm file.
    ///
    /// \param client_file_ident The server assigned client-side file
    /// identifier. A client-side file identifier is a non-zero positive integer
    /// strictly less than 2**64. The server guarantees that all client-side
    /// file identifiers generated on behalf of a particular server Realm are
    /// unique with respect to each other. The server is free to generate
    /// identical identifiers for two client files if they are associated with
    /// different server Realms.
    ///
    /// \param fix_up_object_ids The object ids that depend on client file ident
    /// will be fixed in both state and history if this parameter is true. If
    /// it is known that there are no objects to fix, it can be set to false to
    /// achieve higher performance.
    ///
    /// The client is required to obtain the file identifier before engaging in
    /// synchronization proper, and it must store the identifier and use it to
    /// reestablish the connection between the client file and the server file
    /// when engaging in future synchronization sessions.
    virtual void set_client_file_ident(SaltedFileIdent client_file_ident, bool fix_up_object_ids) = 0;

    /// Stores the synchronization progress in the associated Realm file in a
    /// way that makes it available via get_status() during future
    /// synchronization sessions. Progress is reported by the server in the
    /// DOWNLOAD message.
    ///
    /// See struct SyncProgress for a description of \a progress.
    ///
    /// \param downloadable_bytes If specified, and if the implementation cares
    /// about byte-level progress, this function updates the persistent record
    /// of the estimate of the number of remaining bytes to be downloaded.
    virtual void set_sync_progress(const SyncProgress& progress, const std::uint_fast64_t* downloadable_bytes,
                                   VersionInfo&) = 0;

    struct UploadChangeset {
        timestamp_type origin_timestamp;
        file_ident_type origin_file_ident;
        UploadCursor progress;
        ChunkedBinaryData changeset;
        std::unique_ptr<char[]> buffer;
    };

    /// \brief Scan through the history for changesets to be uploaded.
    ///
    /// This function scans the history for changesets to be uploaded, i.e., for
    /// changesets that are not empty, and were not produced by integration of
    /// changesets recieved from the server. The scan begins at the position
    /// specified by the initial value of \a upload_progress.client_version, and
    /// ends no later than at the position specified by \a end_version.
    ///
    /// The implementation is allowed to end the scan before \a end_version,
    /// such as to limit the combined size of returned changesets. However, if
    /// the specified range contains any changesets that are supposed to be
    /// uploaded, this function must return at least one.
    ///
    /// Upon return, \a upload_progress will have been updated to point to the
    /// position from which the next scan should resume. This must be a position
    /// after the last returned changeset, and before any remaining changesets
    /// that are supposed to be uploaded, although never a position that
    /// succeeds \a end_version.
    ///
    /// The value passed as \a upload_progress by the caller, must either be one
    /// that was produced by an earlier invocation of
    /// find_uploadable_changesets(), one that was returned by get_status(), or
    /// one that was received by the client in a DOWNLOAD message from the
    /// server. When the value comes from a DOWNLOAD message, it is supposed to
    /// reflect a value of UploadChangeset::progress produced by an earlier
    /// invocation of find_uploadable_changesets().
    ///
    /// Found changesets are added to \a uploadable_changesets.
    ///
    /// \param locked_server_version will be set to the value that should be
    /// used as `<locked server version>` in a DOWNLOAD message.
    ///
    /// For changesets of local origin, UploadChangeset::origin_file_ident will
    /// be zero.
    virtual void find_uploadable_changesets(UploadCursor& upload_progress, version_type end_version,
                                            std::vector<UploadChangeset>& uploadable_changesets,
                                            version_type& locked_server_version) const = 0;

    using RemoteChangeset = Transformer::RemoteChangeset;

    // FIXME: Apparently, this feature is expected by object store, but why?
    // What is it ultimately used for? (@tgoyne)
    class SyncTransactReporter {
    public:
        virtual void report_sync_transact(VersionID old_version, VersionID new_version) = 0;

    protected:
        ~SyncTransactReporter() {}
    };

    enum class IntegrationError { bad_origin_file_ident, bad_changeset };

    /// \brief Integrate a sequence of changesets received from the server using
    /// a single Realm transaction.
    ///
    /// Each changeset will be transformed as if by a call to
    /// Transformer::transform_remote_changeset(), and then applied to the
    /// associated Realm.
    ///
    /// As a final step, each changeset will be added to the local history (list
    /// of applied changesets).
    ///
    /// This function checks whether the specified changesets specify valid
    /// remote origin file identifiers and whether the changesets contain valid
    /// sequences of instructions. The caller must already have ensured that the
    /// origin file identifiers are strictly positive and not equal to the file
    /// identifier assigned to this client by the server.
    ///
    /// If any of the changesets are invalid, this function returns false and
    /// sets `integration_error` to the appropriate value. If they are all
    /// deemed valid, this function updates \a version_info to reflect the new
    /// version produced by the transaction.
    ///
    /// \param progress The synchronization progress is what was received in the
    /// DOWNLOAD message along with the specified changesets. The progress will
    /// be persisted along with the changesets.
    ///
    /// \param downloadable_bytes If specified, and if the implementation cares
    /// about byte-level progress, this function updates the persistent record
    /// of the estimate of the number of remaining bytes to be downloaded.
    ///
    /// \param num_changesets The number of passed changesets. Must be non-zero.
    ///
    /// \param transact_reporter An optional callback which will be called with the
    /// version immediately processing the sync transaction and that of the sync
    /// transaction.
    virtual bool integrate_server_changesets(const SyncProgress& progress,
                                             const std::uint_fast64_t* downloadable_bytes,
                                             const RemoteChangeset* changesets, std::size_t num_changesets,
                                             VersionInfo& new_version, IntegrationError& integration_error,
                                             util::Logger&, SyncTransactReporter* transact_reporter = nullptr) = 0;

protected:
    ClientReplicationBase(const std::string& realm_path);
};


class ClientReplication : public ClientReplicationBase {
public:
    /// Get the persisted upload/download progress in bytes.
    virtual void get_upload_download_bytes(std::uint_fast64_t& downloaded_bytes,
                                           std::uint_fast64_t& downloadable_bytes, std::uint_fast64_t& uploaded_bytes,
                                           std::uint_fast64_t& uploadable_bytes,
                                           std::uint_fast64_t& snapshot_version) = 0;

    /// Return an upload cursor as it would be when the uploading process
    /// reaches the snapshot to which the current transaction is bound.
    ///
    /// **CAUTION:** Must be called only while a transaction (read or write) is
    /// in progress via the SharedGroup object associated with this history
    /// object.
    virtual UploadCursor get_upload_anchor_of_current_transact(const Transaction&) const = 0;

    /// Return the synchronization changeset of the current transaction as it
    /// would be if that transaction was committed at this time.
    ///
    /// The returned memory reference may be invalidated by subsequent
    /// operations on the Realm state.
    ///
    /// **CAUTION:** Must be called only while a write transaction is in
    /// progress via the SharedGroup object associated with this history object.
    virtual util::StringView get_sync_changeset_of_current_transact(const Transaction&) const noexcept = 0;

protected:
    ClientReplication(const std::string& realm_path);
};


/// \brief Create a "sync history" implementation of the realm::Replication
/// interface.
///
/// The intended role for such an object is as a plugin for new
/// realm::DB objects.
std::unique_ptr<ClientReplication> make_client_replication(const std::string& realm_path);


// Implementation

inline ClientReplicationBase::ClientReplicationBase(const std::string& realm_path)
    : SyncReplication{realm_path} // Throws
{
}

inline timestamp_type generate_changeset_timestamp() noexcept
{
    namespace chrono = std::chrono;
    // Unfortunately, C++11 does not specify what the epoch is for
    // `chrono::system_clock` (or for any other clock). It is believed, however,
    // that there is a de-facto standard, that the Epoch for
    // `chrono::system_clock` is the Unix epoch, i.e., 1970-01-01T00:00:00Z. See
    // http://stackoverflow.com/a/29800557/1698548. Additionally, it is assumed
    // that leap seconds are not included in the value returned by
    // time_since_epoch(), i.e., that it conforms to POSIX time. This is known
    // to be true on Linux.
    //
    // FIXME: Investigate under which conditions OS X agrees with POSIX about
    // not including leap seconds in the value returned by time_since_epoch().
    //
    // FIXME: Investigate whether Microsoft Windows agrees with POSIX about
    // about not including leap seconds in the value returned by
    // time_since_epoch().
    auto time_since_epoch = chrono::system_clock::now().time_since_epoch();
    std::uint_fast64_t millis_since_epoch = chrono::duration_cast<chrono::milliseconds>(time_since_epoch).count();
    // `offset_in_millis` is the number of milliseconds between
    // 1970-01-01T00:00:00Z and 2015-01-01T00:00:00Z not counting leap seconds.
    std::uint_fast64_t offset_in_millis = 1420070400000ULL;
    return timestamp_type(millis_since_epoch - offset_in_millis);
}

inline void map_changeset_timestamp(timestamp_type timestamp, std::time_t& seconds_since_epoch,
                                    long& nanoseconds) noexcept
{
    std::uint_fast64_t offset_in_millis = 1420070400000ULL;
    std::uint_fast64_t millis_since_epoch = std::uint_fast64_t(offset_in_millis + timestamp);
    seconds_since_epoch = std::time_t(millis_since_epoch / 1000);
    nanoseconds = long(millis_since_epoch % 1000 * 1000000L);
}

inline ClientReplication::ClientReplication(const std::string& realm_path)
    : ClientReplicationBase{realm_path} // Throws
{
}

} // namespace sync
} // namespace realm

#endif // REALM_SYNC_HISTORY_HPP
