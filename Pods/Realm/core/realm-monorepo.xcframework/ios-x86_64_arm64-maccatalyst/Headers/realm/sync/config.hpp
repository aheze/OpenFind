////////////////////////////////////////////////////////////////////////////
//
// Copyright 2016 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

#ifndef REALM_SYNC_CONFIG_HPP
#define REALM_SYNC_CONFIG_HPP

#include <realm/util/assert.hpp>
#include <realm/util/optional.hpp>
#include <realm/util/network.hpp>

#include <functional>
#include <memory>
#include <string>
#include <map>
#include <array>
#include <system_error>
#include <unordered_map>

namespace realm {

class Group;
class SyncUser;
class SyncSession;

namespace bson {
class Bson;
}

struct SyncError {

    std::error_code error_code;
    std::string message;
    bool is_fatal;
    std::unordered_map<std::string, std::string> user_info;
    /// The sync server may send down an error that the client does not recognize,
    /// whether because of a version mismatch or an oversight. It is still valuable
    /// to expose these errors so that users can do something about them.
    bool is_unrecognized_by_client = false;

    SyncError(std::error_code error_code, std::string message, bool is_fatal)
        : error_code(std::move(error_code))
        , message(std::move(message))
        , is_fatal(is_fatal)
    {
    }

    static constexpr const char c_original_file_path_key[] = "ORIGINAL_FILE_PATH";
    static constexpr const char c_recovery_file_path_key[] = "RECOVERY_FILE_PATH";

    /// The error is a client error, which applies to the client and all its sessions.
    bool is_client_error() const;

    /// The error is a protocol error, which may either be connection-level or session-level.
    bool is_connection_level_protocol_error() const;

    /// The error is a connection-level protocol error.
    bool is_session_level_protocol_error() const;

    /// The error indicates a client reset situation.
    bool is_client_reset_requested() const;
};

using SyncSessionErrorHandler = void(std::shared_ptr<SyncSession>, SyncError);

enum class ClientResyncMode : unsigned char {
    // Enable automatic client resync with local transaction recovery
    Recover = 0,
    // Enable automatic client resync without local transaction recovery
    DiscardLocal = 1,
    // Fire a client reset error
    Manual = 2,
};

enum class ReconnectMode {
    /// This is the mode that should always be used in production. In this
    /// mode the client uses a scheme for determining a reconnect delay that
    /// prevents it from creating too many connection requests in a short
    /// amount of time (i.e., a server hammering protection mechanism).
    normal,

    /// For testing purposes only.
    ///
    /// Never reconnect automatically after the connection is closed due to
    /// an error. Allow immediate reconnect if the connection was closed
    /// voluntarily (e.g., due to sessions being abandoned).
    ///
    /// In this mode, Client::cancel_reconnect_delay() and
    /// Session::cancel_reconnect_delay() can still be used to trigger
    /// another reconnection attempt (with no delay) after an error has
    /// caused the connection to be closed.
    testing
};

enum class SyncSessionStopPolicy {
    Immediately,          // Immediately stop the session as soon as all Realms/Sessions go out of scope.
    LiveIndefinitely,     // Never stop the session.
    AfterChangesUploaded, // Once all Realms/Sessions go out of scope, wait for uploads to complete and stop.
};

/// \brief Abstract interface for changeset cookers.
///
/// Note, it is completely up to the application to decide what a cooked
/// changeset is. History objects (instances of ClientHistory) are required to
/// treat cooked changesets as opaque entities. For an example of a concrete
/// changeset cooker, see TrivialChangesetCooker which defines the cooked
/// changesets to be identical copies of the raw changesets.
class ChangesetCooker {
public:
    virtual ~ChangesetCooker() {}

    /// \brief An opportunity to produce a cooked changeset.
    ///
    /// When the implementation chooses to produce a cooked changeset, it must
    /// write the cooked changeset to the specified buffer, and return
    /// true. When the implementation chooses not to produce a cooked changeset,
    /// it must return false. The implementation is allowed to write to the
    /// buffer, and return false, and in that case, the written data will be
    /// ignored.
    ///
    /// \param prior_state The state of the local Realm on which the specified
    /// raw changeset is based.
    ///
    /// \param changeset changeset_size The raw changeset.
    ///
    /// \param buffer The buffer to which the cooked changeset must be written.
    ///
    /// \return True if a cooked changeset was produced. Otherwise false.
    virtual bool cook_changeset(const Group& prior_state, const char* changeset, std::size_t changeset_size,
                                util::AppendBuffer<char>& buffer) = 0;
};

struct SyncConfig {
    struct ProxyConfig {
        using port_type = util::network::Endpoint::port_type;
        enum class Type { HTTP, HTTPS } type;
        std::string address;
        port_type port;
    };
    using SSLVerifyCallback = bool(const std::string& server_address, ProxyConfig::port_type server_port,
                                   const char* pem_data, size_t pem_size, int preverify_ok, int depth);

    std::shared_ptr<SyncUser> user;
    std::string partition_value;
    SyncSessionStopPolicy stop_policy = SyncSessionStopPolicy::AfterChangesUploaded;
    std::function<SyncSessionErrorHandler> error_handler;
    std::shared_ptr<ChangesetCooker> transformer;
    util::Optional<std::array<char, 64>> realm_encryption_key;
    bool client_validate_ssl = true;
    util::Optional<std::string> ssl_trust_certificate_path;
    std::function<SSLVerifyCallback> ssl_verify_callback;
    util::Optional<ProxyConfig> proxy_config;

    // If true, upload/download waits are canceled on any sync error and not just fatal ones
    bool cancel_waits_on_nonfatal_error = false;

    util::Optional<std::string> authorization_header_name;
    std::map<std::string, std::string> custom_http_headers;

    // The name of the directory which Realms should be backed up to following
    // a client reset
    util::Optional<std::string> recovery_directory;
    ClientResyncMode client_resync_mode = ClientResyncMode::Recover;

    explicit SyncConfig(std::shared_ptr<SyncUser> user, bson::Bson partition);
    explicit SyncConfig(std::shared_ptr<SyncUser> user, std::string partition);
    explicit SyncConfig(std::shared_ptr<SyncUser> user, const char* partition);
};

} // namespace realm

#endif // REALM_SYNC_CONFIG_HPP
