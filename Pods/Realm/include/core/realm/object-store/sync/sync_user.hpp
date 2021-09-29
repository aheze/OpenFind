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

#ifndef REALM_OS_SYNC_USER_HPP
#define REALM_OS_SYNC_USER_HPP

#include <realm/object-store/object_schema.hpp>
#include <realm/object-store/util/atomic_shared_ptr.hpp>
#include <realm/object-store/util/bson/bson.hpp>
#include <realm/object-store/sync/subscribable.hpp>

#include <realm/util/any.hpp>
#include <realm/util/optional.hpp>
#include <realm/table.hpp>

#include <map>
#include <memory>
#include <mutex>
#include <string>
#include <unordered_map>
#include <vector>

namespace realm {
namespace app {
struct AppError;
class MongoClient;
} // namespace app
class SyncSession;
class SyncManager;

// A superclass that bindings can inherit from in order to store information
// upon a `SyncUser` object.
class SyncUserContext {
public:
    virtual ~SyncUserContext() = default;
};

using SyncUserContextFactory = std::function<std::shared_ptr<SyncUserContext>()>;

// A struct that decodes a given JWT.
struct RealmJWT {
    // The token being decoded from.
    std::string token;

    // When the token expires.
    int64_t expires_at = 0;
    // When the token was issued.
    int64_t issued_at = 0;
    // Custom user data embedded in the encoded token.
    util::Optional<bson::BsonDocument> user_data;

    explicit RealmJWT(const std::string& token);
    RealmJWT() = default;

    bool operator==(const RealmJWT& other) const
    {
        return token == other.token;
    }
};

struct SyncUserProfile {
    // The full name of the user.
    util::Optional<std::string> name() const
    {
        if (m_data.find("name") == m_data.end()) {
            return util::none;
        }
        return static_cast<std::string>(m_data.at("name"));
    }
    // The email address of the user.
    util::Optional<std::string> email() const
    {
        if (m_data.find("email") == m_data.end()) {
            return util::none;
        }
        return static_cast<std::string>(m_data.at("email"));
    }
    // A URL to the user's profile picture.
    util::Optional<std::string> picture_url() const
    {
        if (m_data.find("picture_url") == m_data.end()) {
            return util::none;
        }
        return static_cast<std::string>(m_data.at("picture_url"));
    }
    // The first name of the user.
    util::Optional<std::string> first_name() const
    {
        if (m_data.find("first_name") == m_data.end()) {
            return util::none;
        }
        return static_cast<std::string>(m_data.at("first_name"));
    }
    // The last name of the user.
    util::Optional<std::string> last_name() const
    {
        if (m_data.find("last_name") == m_data.end()) {
            return util::none;
        }
        return static_cast<std::string>(m_data.at("last_name"));
    }
    // The gender of the user.
    util::Optional<std::string> gender() const
    {
        if (m_data.find("gender") == m_data.end()) {
            return util::none;
        }
        return static_cast<std::string>(m_data.at("gender"));
    }
    // The birthdate of the user.
    util::Optional<std::string> birthday() const
    {
        if (m_data.find("birthday") == m_data.end()) {
            return util::none;
        }
        return static_cast<std::string>(m_data.at("birthday"));
    }
    // The minimum age of the user.
    util::Optional<std::string> min_age() const
    {
        if (m_data.find("min_age") == m_data.end()) {
            return util::none;
        }
        return static_cast<std::string>(m_data.at("min_age"));
    }
    // The maximum age of the user.
    util::Optional<std::string> max_age() const
    {
        if (m_data.find("max_age") == m_data.end()) {
            return util::none;
        }
        return static_cast<std::string>(m_data.at("max_age"));
    }

    bson::Bson operator[](const std::string& key) const
    {
        return m_data.at(key);
    }

    bson::BsonDocument data() const
    {
        return m_data;
    }

    SyncUserProfile(bson::BsonDocument&& data)
        : m_data(std::move(data))
    {
    }
    SyncUserProfile() = default;

private:
    bson::BsonDocument m_data;
};

// A struct that represents an identity that a `User` is linked to
struct SyncUserIdentity {
    // the id of the identity
    std::string id;
    // the associated provider type of the identity
    std::string provider_type;

    SyncUserIdentity(const std::string& id, const std::string& provider_type);

    bool operator==(const SyncUserIdentity& other) const
    {
        return id == other.id && provider_type == other.provider_type;
    }

    bool operator!=(const SyncUserIdentity& other) const
    {
        return id != other.id || provider_type != other.provider_type;
    }
};

// A `SyncUser` represents a single user account. Each user manages the sessions that
// are associated with it.
class SyncUser : public std::enable_shared_from_this<SyncUser>, public Subscribable<SyncUser> {
    friend class SyncSession;

public:
    enum class State : std::size_t {
        LoggedOut,
        LoggedIn,
        Removed,
    };

    // Don't use this directly; use the `SyncManager` APIs. Public for use with `make_shared`.
    SyncUser(std::string refresh_token, const std::string id, const std::string provider_type,
             std::string access_token, SyncUser::State state, const std::string device_id, SyncManager* sync_manager);

    ~SyncUser();

    // Return a list of all sessions belonging to this user.
    std::vector<std::shared_ptr<SyncSession>> all_sessions();

    // Return a session for a given on disk path.
    // In most cases, bindings shouldn't expose this to consumers, since the on-disk
    // path for a synced Realm is an opaque implementation detail. This API is retained
    // for testing purposes, and for bindings for consumers that are servers or tools.
    std::shared_ptr<SyncSession> session_for_on_disk_path(const std::string& path);

    // Update the user's state and refresh/access tokens atomically in a Realm transaction.
    // If the user is transitioning between LoggedIn and LoggedOut, then the access_token and
    // refresh token must be empty, and likewise must not be empty if transitioning between
    // logged out and logged in.
    // Note that this is called by the SyncManager, and should not be directly called.
    void update_state_and_tokens(SyncUser::State state, const std::string& access_token,
                                 const std::string& refresh_token);

    // Update the user's refresh token. If the user is logged out, it will log itself back in.
    // Note that this is called by the SyncManager, and should not be directly called.
    void update_refresh_token(std::string&& token);

    // Update the user's access token. If the user is logged out, it will log itself back in.
    // Note that this is called by the SyncManager, and should not be directly called.
    void update_access_token(std::string&& token);

    // Update the user's profile.
    void update_user_profile(const SyncUserProfile& profile);

    // Update the user's identities.
    void update_identities(std::vector<SyncUserIdentity> identities);

    // Log the user out and mark it as such. This will also close its associated Sessions.
    void log_out();

    /// Returns true id the users access_token and refresh_token are set.
    bool is_logged_in() const;

    const std::string& identity() const noexcept
    {
        return m_identity;
    }

    const std::string& provider_type() const noexcept
    {
        return m_provider_type;
    }

    const std::string& local_identity() const noexcept
    {
        return m_local_identity;
    }

    std::string access_token() const;

    std::string refresh_token() const;

    RealmJWT refresh_jwt() const
    {
        return m_refresh_token;
    }

    std::string device_id() const;

    bool has_device_id() const;

    SyncUserProfile user_profile() const;

    std::vector<SyncUserIdentity> identities() const;

    // Custom user data embedded in the access token.
    util::Optional<bson::BsonDocument> custom_data() const;

    State state() const;
    void set_state(SyncUser::State state);

    std::shared_ptr<SyncUserContext> binding_context() const
    {
        return m_binding_context.load();
    }

    // Register a session to this user.
    // A registered session will be bound at the earliest opportunity: either
    // immediately, or upon the user becoming Active.
    // Note that this is called by the SyncManager, and should not be directly called.
    void register_session(std::shared_ptr<SyncSession>);

    /// Refreshes the custom data for this user
    void refresh_custom_data(std::function<void(util::Optional<app::AppError>)> completion_block);

    /// Checks the expiry on the access token against the local time and if it is invalid or expires soon, returns
    /// true.
    bool access_token_refresh_required() const;

    // Optionally set a context factory. If so, must be set before any sessions are created.
    static void set_binding_context_factory(SyncUserContextFactory factory);

    std::shared_ptr<SyncManager> sync_manager() const;

    /// Retrieves a general-purpose service client for the Realm Cloud service
    /// @param service_name The name of the cluster
    app::MongoClient mongo_client(const std::string& service_name);

protected:
    friend class SyncManager;
    void detach_from_sync_manager();

private:
    static SyncUserContextFactory s_binding_context_factory;
    static std::mutex s_binding_context_factory_mutex;

    State m_state;

    util::AtomicSharedPtr<SyncUserContext> m_binding_context;

    // A locally assigned UUID intended to provide a level of indirection for various features.
    std::string m_local_identity;

    // The auth provider used to login this user.
    const std::string m_provider_type;

    // Mark the user as invalid, since a fatal user-related error was encountered.
    void invalidate();

    mutable std::mutex m_mutex;

    // The user's refresh token.
    RealmJWT m_refresh_token;

    // Set by the server. The unique ID of the user account on the Realm Applcication.
    const std::string m_identity;

    // Sessions are owned by the SyncManager, but the user keeps a map of weak references
    // to them.
    std::unordered_map<std::string, std::weak_ptr<SyncSession>> m_sessions;

    // Waiting sessions are those that should be asked to connect once this user is logged in.
    std::unordered_map<std::string, std::weak_ptr<SyncSession>> m_waiting_sessions;

    // The user's access token.
    RealmJWT m_access_token;

    // The identities associated with this user.
    std::vector<SyncUserIdentity> m_user_identities;

    SyncUserProfile m_user_profile;

    const std::string m_device_id;

    SyncManager* m_sync_manager;
};

} // namespace realm

namespace std {
template <>
struct hash<realm::SyncUserIdentity> {
    size_t operator()(realm::SyncUserIdentity const&) const;
};
} // namespace std

#endif // REALM_OS_SYNC_USER_HPP
