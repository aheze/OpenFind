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

#ifndef REALM_OS_SYNC_MANAGER_HPP
#define REALM_OS_SYNC_MANAGER_HPP

#include <realm/object-store/shared_realm.hpp>

#include <realm/object-store/sync/app.hpp>
#include <realm/object-store/sync/sync_user.hpp>

#include <realm/util/logger.hpp>
#include <realm/util/optional.hpp>
#include <realm/sync/config.hpp>

#include <memory>
#include <mutex>
#include <unordered_map>

struct TestSyncManager;

namespace realm {

class DB;
struct SyncConfig;
class SyncSession;
class SyncUser;
class SyncFileManager;
class SyncMetadataManager;
class SyncFileActionMetadata;
class SyncAppMetadata;

namespace _impl {
struct SyncClient;
}

class SyncLoggerFactory {
public:
    virtual std::unique_ptr<util::Logger> make_logger(util::Logger::Level) = 0;
};

struct SyncClientTimeouts {
    SyncClientTimeouts();
    // See sync::Client::Config for the meaning of these fields.
    uint64_t connect_timeout;
    uint64_t connection_linger_time;
    uint64_t ping_keepalive_period;
    uint64_t pong_keepalive_timeout;
    uint64_t fast_reconnect_limit;
};

struct SyncClientConfig {
    enum class MetadataMode {
        NoEncryption, // Enable metadata, but disable encryption.
        Encryption,   // Enable metadata, and use encryption (automatic if possible).
        NoMetadata,   // Disable metadata.
    };

    std::string base_file_path;
    MetadataMode metadata_mode = MetadataMode::Encryption;
    util::Optional<std::vector<char>> custom_encryption_key;
    bool reset_metadata_on_error = false;

    SyncLoggerFactory* logger_factory = nullptr;
    // FIXME: Should probably be util::Logger::Level::error
    util::Logger::Level log_level = util::Logger::Level::info;
    ReconnectMode reconnect_mode = ReconnectMode::normal;
    bool multiplex_sessions = false;

    // Optional information about the binding/application that is sent as part of the User-Agent
    // when establishing a connection to the server.
    std::string user_agent_binding_info;
    std::string user_agent_application_info;

    SyncClientTimeouts timeouts;
};

class SyncManager : public std::enable_shared_from_this<SyncManager> {
    friend class SyncSession;
    friend struct ::TestSyncManager;

public:
    using MetadataMode = SyncClientConfig::MetadataMode;

    // Immediately run file actions for a single Realm at a given original path.
    // Returns whether or not a file action was successfully executed for the specified Realm.
    // Preconditions: all references to the Realm at the given path must have already been invalidated.
    // The metadata and file management subsystems must also have already been configured.
    bool immediately_run_file_actions(const std::string& original_name);

    // Use a single connection for all sync sessions for each host/port rather
    // than one per session.
    // This must be called before any sync sessions are created, cannot be
    // disabled afterwards, and currently is incompatible with automatic failover.
    void enable_session_multiplexing();

    // Destroys the sync manager, terminates all sessions created by it, and stops its SyncClient.
    ~SyncManager();

    // Sets the log level for the Sync Client.
    // The log level can only be set up until the point the Sync Client is created. This happens when the first
    // Session is created.
    void set_log_level(util::Logger::Level) noexcept;
    void set_logger_factory(SyncLoggerFactory&) noexcept;

    // Create a new logger of the type which will be used by the sync client
    std::unique_ptr<util::Logger> make_logger() const;

    // Sets the application level user agent string.
    // This should have the format specified here:
    // https://github.com/realm/realm-sync/blob/develop/src/realm/sync/client.hpp#L126 The user agent can only be set
    // up  until the  point the Sync Client is created. This happens when the first Session is created.
    void set_user_agent(std::string user_agent);

    // Sets client timeout settings.
    // The timeout settings can only be set up until the point the Sync Client is created.
    // This happens when the first Session is created.
    void set_timeouts(SyncClientTimeouts timeouts);

    /// Ask all valid sync sessions to perform whatever tasks might be necessary to
    /// re-establish connectivity with the Realm Object Server. It is presumed that
    /// the caller knows that network connectivity has been restored.
    ///
    /// Refer to `SyncSession::handle_reconnect()` to see what sort of work is done
    /// on a per-session basis.
    void reconnect() const;

    util::Logger::Level log_level() const noexcept;

    std::shared_ptr<SyncSession> get_session(std::shared_ptr<DB> db, const SyncConfig& config);
    std::shared_ptr<SyncSession> get_existing_session(const std::string& path) const;
    std::shared_ptr<SyncSession> get_existing_active_session(const std::string& path) const;

    // Returns `true` if the SyncManager still contains any existing sessions not yet fully cleaned up.
    // This will return true as long as there is an external reference to a session object, no matter
    // the state of that session.
    bool has_existing_sessions();

    // Blocking call that only return once all sessions have been terminated.
    // Due to the async nature of the SyncClient, even with `SyncSessionStopPolicy::Immediate`, a
    // session is not guaranteed to stop immediately when a Realm is closed. Using this method
    // makes it possible to guarantee that all sessions have, in fact, been closed.
    void wait_for_sessions_to_terminate();

    // If the metadata manager is configured, perform an update. Returns `true` iff the code was run.
    bool perform_metadata_update(std::function<void(const SyncMetadataManager&)> update_function) const;

    // Get a sync user for a given identity, or create one if none exists yet, and set its token.
    // If a logged-out user exists, it will marked as logged back in.
    std::shared_ptr<SyncUser> get_user(const std::string& id, std::string refresh_token, std::string access_token,
                                       const std::string provider_type, std::string device_id);

    // Get an existing user for a given identifier, if one exists and is logged in.
    std::shared_ptr<SyncUser> get_existing_logged_in_user(const std::string& user_id) const;

    // Get all the users that are logged in and not errored out.
    std::vector<std::shared_ptr<SyncUser>> all_users();

    // Gets the currently active user.
    std::shared_ptr<SyncUser> get_current_user() const;

    // Log out a given user
    void log_out_user(const std::string& user_id);

    // Sets the currently active user.
    void set_current_user(const std::string& user_id);

    // Removes a user
    void remove_user(const std::string& user_id);

    // Get the default path for a Realm for the given user and absolute unresolved URL.
    // If the default path of `<rootDir>/<appId>/<userId>/<realm_file_name>.realm` cannot
    // be created, this function may pass back `<rootDir>/<hashedFileName>.realm`
    std::string path_for_realm(const SyncUser& user, const std::string& realm_file_name) const;

    // Get the default path for a Realm for the given configuration.
    // The default value is `<rootDir>/<appId>/<userId>/<partitionValue>.realm`.
    // If the file cannot be created at this location, for example due to path length restrictions,
    // this function may pass back `<rootDir>/<hashedFileName>.realm`
    std::string path_for_realm(const SyncConfig& config, util::Optional<std::string> custom_file_name = none) const;

    // Get the path of the recovery directory for backed-up or recovered Realms.
    std::string recovery_directory_path(util::Optional<std::string> const& custom_dir_name = none) const;

    // Get the unique identifier of this client.
    std::string client_uuid() const;

    // Reset the singleton state for testing purposes. DO NOT CALL OUTSIDE OF TESTING CODE.
    // Precondition: any synced Realms or `SyncSession`s must be closed or rendered inactive prior to
    // calling this method.
    void reset_for_testing();

    // Get the app metadata for the active app.
    util::Optional<SyncAppMetadata> app_metadata() const;

    void set_sync_route(std::string sync_route)
    {
        std::lock_guard<std::mutex> lock(m_mutex);
        m_sync_route = std::move(sync_route);
    }

    const std::string sync_route() const
    {
        std::lock_guard<std::mutex> lock(m_mutex);
        return m_sync_route;
    }

    std::weak_ptr<app::App> app() const
    {
        std::lock_guard<std::mutex> lock(m_mutex);
        return m_app;
    }

    SyncManager() = default;
    SyncManager(const SyncManager&) = delete;
    SyncManager& operator=(const SyncManager&) = delete;

protected:
    friend class SyncUser;
    friend class SyncSesson;

    using std::enable_shared_from_this<SyncManager>::shared_from_this;
    using std::enable_shared_from_this<SyncManager>::weak_from_this;

private:
    friend class app::App;

    void configure(std::shared_ptr<app::App> app, const std::string& sync_route, const SyncClientConfig& config);

    // Stop tracking the session for the given path if it is inactive.
    // No-op if the session is either still active or in the active sessions list
    // due to someone holding a strong reference to it.
    void unregister_session(const std::string& path);

    _impl::SyncClient& get_sync_client() const;
    std::unique_ptr<_impl::SyncClient> create_sync_client() const;

    std::shared_ptr<SyncSession> get_existing_session_locked(const std::string& path) const;

    std::shared_ptr<SyncUser> get_user_for_identity(std::string const& identity) const noexcept;

    mutable std::mutex m_mutex;

    bool run_file_action(const SyncFileActionMetadata&);
    void init_metadata(SyncClientConfig config, const std::string& app_id);

    // Protects m_users
    mutable std::mutex m_user_mutex;

    // A vector of all SyncUser objects.
    std::vector<std::shared_ptr<SyncUser>> m_users;
    std::shared_ptr<SyncUser> m_current_user;

    mutable std::unique_ptr<_impl::SyncClient> m_sync_client;

    SyncClientConfig m_config;

    // Protects m_file_manager and m_metadata_manager
    mutable std::mutex m_file_system_mutex;
    std::unique_ptr<SyncFileManager> m_file_manager;
    std::unique_ptr<SyncMetadataManager> m_metadata_manager;

    // Protects m_sessions
    mutable std::mutex m_session_mutex;

    // Map of sessions by path name.
    // Sessions remove themselves from this map by calling `unregister_session` once they're
    // inactive and have performed any necessary cleanup work.
    std::unordered_map<std::string, std::shared_ptr<SyncSession>> m_sessions;

    // Internal method returning `true` if the SyncManager still contains sessions not yet fully closed.
    // Callers of this method should hold the `m_session_mutex` themselves.
    bool do_has_existing_sessions();

    // The unique identifier of this client.
    util::Optional<std::string> m_client_uuid;

    std::string m_sync_route;

    std::weak_ptr<app::App> m_app;
};

} // namespace realm

#endif // REALM_OS_SYNC_MANAGER_HPP
