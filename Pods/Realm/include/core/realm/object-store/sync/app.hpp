////////////////////////////////////////////////////////////////////////////
//
// Copyright 2020 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or utilied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

#ifndef REALM_APP_HPP
#define REALM_APP_HPP

#include <realm/object-store/sync/app_credentials.hpp>
#include <realm/object-store/sync/app_service_client.hpp>
#include <realm/object-store/sync/auth_request_client.hpp>
#include <realm/object-store/sync/generic_network_transport.hpp>
#include <realm/object-store/sync/push_client.hpp>
#include <realm/object-store/sync/subscribable.hpp>

#include <realm/object_id.hpp>
#include <realm/util/optional.hpp>

#include <mutex>

namespace realm {

class SyncUser;
class SyncSession;
class SyncManager;
struct SyncClientConfig;

namespace app {

class App;

typedef std::shared_ptr<App> SharedApp;

/// The `App` has the fundamental set of methods for communicating with a MongoDB Realm application backend.
///
/// This class provides access to login and authentication.
///
/// You can also use it to execute [Functions](https://docs.mongodb.com/stitch/functions/).
class App : public std::enable_shared_from_this<App>,
            public AuthRequestClient,
            public AppServiceClient,
            public Subscribable<App> {
public:
    struct Config {
        std::string app_id;
        GenericNetworkTransport::NetworkTransportFactory transport_generator;
        util::Optional<std::string> base_url;
        util::Optional<std::string> local_app_name;
        util::Optional<std::string> local_app_version;
        util::Optional<uint64_t> default_request_timeout_ms;
        std::string platform;
        std::string platform_version;
        std::string sdk_version;
    };

    // `enable_shared_from_this` is unsafe with public constructors; use `get_shared_app` instead
    App(const Config& config);
    App(App&&) noexcept = default;
    App& operator=(App&&) noexcept = default;
    ~App();

    const Config& config() const
    {
        return m_config;
    }

    const std::string& base_url() const
    {
        return m_base_url;
    }

    /// Get the last used user.
    std::shared_ptr<SyncUser> current_user() const;

    /// Get all users.
    std::vector<std::shared_ptr<SyncUser>> all_users() const;

    std::shared_ptr<SyncManager> sync_manager() const
    {
        return m_sync_manager;
    }

    /// A struct representing a user API key as returned by the App server.
    struct UserAPIKey {
        // The ID of the key.
        ObjectId id;

        /// The actual key. Will only be included in
        /// the response when an API key is first created.
        util::Optional<std::string> key;

        /// The name of the key.
        std::string name;

        /// Whether or not the key is disabled.
        bool disabled;
    };

    /// A client for the user API key authentication provider which
    /// can be used to create and modify user API keys. This
    /// client should only be used by an authenticated user.
    class UserAPIKeyProviderClient {
    public:
        /// Creates a user API key that can be used to authenticate as the current user.
        /// @param name The name of the API key to be created.
        /// @param completion_block A callback to be invoked once the call is complete.
        void create_api_key(const std::string& name, std::shared_ptr<SyncUser> user,
                            std::function<void(UserAPIKey, util::Optional<AppError>)> completion_block);

        /// Fetches a user API key associated with the current user.
        /// @param id The id of the API key to fetch.
        /// @param completion_block A callback to be invoked once the call is complete.
        void fetch_api_key(const realm::ObjectId& id, std::shared_ptr<SyncUser> user,
                           std::function<void(UserAPIKey, util::Optional<AppError>)> completion_block);

        /// Fetches the user API keys associated with the current user.
        /// @param completion_block A callback to be invoked once the call is complete.
        void fetch_api_keys(std::shared_ptr<SyncUser> user,
                            std::function<void(std::vector<UserAPIKey>, util::Optional<AppError>)> completion_block);

        /// Deletes a user API key associated with the current user.
        /// @param id The id of the API key to delete.
        /// @param user The user to perform this operation.
        /// @param completion_block A callback to be invoked once the call is complete.
        void delete_api_key(const realm::ObjectId& id, std::shared_ptr<SyncUser> user,
                            std::function<void(util::Optional<AppError>)> completion_block);

        /// Enables a user API key associated with the current user.
        /// @param id The id of the API key to enable.
        /// @param user The user to perform this operation.
        /// @param completion_block A callback to be invoked once the call is complete.
        void enable_api_key(const realm::ObjectId& id, std::shared_ptr<SyncUser> user,
                            std::function<void(util::Optional<AppError>)> completion_block);

        /// Disables a user API key associated with the current user.
        /// @param id The id of the API key to disable.
        /// @param user The user to perform this operation.
        /// @param completion_block A callback to be invoked once the call is complete.
        void disable_api_key(const realm::ObjectId& id, std::shared_ptr<SyncUser> user,
                             std::function<void(util::Optional<AppError>)> completion_block);

    private:
        friend class App;
        UserAPIKeyProviderClient(AuthRequestClient& auth_request_client)
            : m_auth_request_client(auth_request_client)
        {
        }

        std::string url_for_path(const std::string& path) const;
        AuthRequestClient& m_auth_request_client;
    };

    /// A client for the username/password authentication provider which
    /// can be used to obtain a credential for logging in,
    /// and to perform requests specifically related to the username/password provider.
    ///
    class UsernamePasswordProviderClient {
    public:
        /// Registers a new email identity with the username/password provider,
        /// and sends a confirmation email to the provided address.
        /// @param email The email address of the user to register.
        /// @param password The password that the user created for the new username/password identity.
        /// @param completion_block A callback to be invoked once the call is complete.
        void register_email(const std::string& email, const std::string& password,
                            std::function<void(util::Optional<AppError>)> completion_block);

        /// Confirms an email identity with the username/password provider.
        /// @param token The confirmation token that was emailed to the user.
        /// @param token_id The confirmation token id that was emailed to the user.
        /// @param completion_block A callback to be invoked once the call is complete.
        void confirm_user(const std::string& token, const std::string& token_id,
                          std::function<void(util::Optional<AppError>)> completion_block);

        /// Re-sends a confirmation email to a user that has registered but
        /// not yet confirmed their email address.
        /// @param email The email address of the user to re-send a confirmation for.
        /// @param completion_block A callback to be invoked once the call is complete.
        void resend_confirmation_email(const std::string& email,
                                       std::function<void(util::Optional<AppError>)> completion_block);

        void send_reset_password_email(const std::string& email,
                                       std::function<void(util::Optional<AppError>)> completion_block);

        /// Retries the custom confirmation function on a user for a given email.
        /// @param email The email address of the user to retry the custom confirmation for.
        /// @param completion_block A callback to be invoked once the retry is complete.
        void retry_custom_confirmation(const std::string& email,
                                       std::function<void(util::Optional<AppError>)> completion_block);

        /// Resets the password of an email identity using the
        /// password reset token emailed to a user.
        /// @param password The desired new password.
        /// @param token The password reset token that was emailed to the user.
        /// @param token_id The password reset token id that was emailed to the user.
        /// @param completion_block A callback to be invoked once the call is complete.
        void reset_password(const std::string& password, const std::string& token, const std::string& token_id,
                            std::function<void(util::Optional<AppError>)> completion_block);

        /// Resets the password of an email identity using the
        /// password reset function set up in the application.
        /// @param email The email address of the user.
        /// @param password The desired new password.
        /// @param args A bson array of arguments.
        /// @param completion_block A callback to be invoked once the call is complete.
        void call_reset_password_function(const std::string& email, const std::string& password,
                                          const bson::BsonArray& args,
                                          std::function<void(util::Optional<AppError>)> completion_block);

    private:
        friend class App;
        UsernamePasswordProviderClient(SharedApp app)
            : m_parent(app)
        {
            REALM_ASSERT(app);
        }
        SharedApp m_parent;
    };

    static SharedApp get_shared_app(const Config& config, const SyncClientConfig& sync_client_config);
    static std::shared_ptr<App> get_cached_app(const std::string& app_id);

    /// Log in a user and asynchronously retrieve a user object.
    /// If the log in completes successfully, the completion block will be called, and a
    /// `SyncUser` representing the logged-in user will be passed to it. This user object
    /// can be used to open `Realm`s and retrieve `SyncSession`s. Otherwise, the
    /// completion block will be called with an error.
    ///
    /// @param credentials A `SyncCredentials` object representing the user to log in.
    /// @param completion_block A callback block to be invoked once the log in completes.
    void log_in_with_credentials(
        const AppCredentials& credentials,
        std::function<void(std::shared_ptr<SyncUser>, util::Optional<AppError>)> completion_block);

    /// Logout the current user.
    void log_out(std::function<void(util::Optional<AppError>)>);

    /// Refreshes the custom data for a specified user
    /// @param sync_user The user you want to refresh
    void refresh_custom_data(std::shared_ptr<SyncUser> sync_user, std::function<void(util::Optional<AppError>)>);

    /// Log out the given user if they are not already logged out.
    void log_out(std::shared_ptr<SyncUser> user, std::function<void(util::Optional<AppError>)> completion_block);

    /// Links the currently authenticated user with a new identity, where the identity is defined by the credential
    /// specified as a parameter. This will only be successful if this `SyncUser` is the currently authenticated
    /// with the client from which it was created. On success the user will be returned with the new identity.
    ///
    /// @param user The user which will have the credentials linked to, the user must be logged in
    /// @param credentials The `AppCredentials` used to link the user to a new identity.
    /// @param completion_block The completion handler to call when the linking is complete.
    ///                         If the operation is  successful, the result will contain the original
    ///                         `SyncUser` object representing the user.
    void link_user(std::shared_ptr<SyncUser> user, const AppCredentials& credentials,
                   std::function<void(std::shared_ptr<SyncUser>, util::Optional<AppError>)> completion_block);

    /// Switches the active user with the specified one. The user must
    /// exist in the list of all users who have logged into this application, and
    /// the user must be currently logged in, otherwise this will throw an
    /// AppError.
    ///
    /// @param user The user to switch to
    /// @returns A shared pointer to the new current user
    std::shared_ptr<SyncUser> switch_user(std::shared_ptr<SyncUser> user) const;

    /// Logs out and removes the provided user.
    /// This invokes logout on the server.
    /// @param user the user to remove
    /// @param completion_block Will return an error if the user is not found or the http request failed.
    void remove_user(std::shared_ptr<SyncUser> user, std::function<void(util::Optional<AppError>)> completion_block);

    // Get a provider client for the given class type.
    template <class T>
    T provider_client()
    {
        return T(this);
    }

    void call_function(
        std::shared_ptr<SyncUser> user, const std::string& name, const bson::BsonArray& args_bson,
        const util::Optional<std::string>& service_name,
        std::function<void(util::Optional<AppError>, util::Optional<bson::Bson>)> completion_block) override;

    void call_function(
        std::shared_ptr<SyncUser> user, const std::string&, const bson::BsonArray& args_bson,
        std::function<void(util::Optional<AppError>, util::Optional<bson::Bson>)> completion_block) override;

    void call_function(
        const std::string& name, const bson::BsonArray& args_bson, const util::Optional<std::string>& service_name,
        std::function<void(util::Optional<AppError>, util::Optional<bson::Bson>)> completion_block) override;

    void call_function(
        const std::string&, const bson::BsonArray& args_bson,
        std::function<void(util::Optional<AppError>, util::Optional<bson::Bson>)> completion_block) override;

    template <typename T>
    void call_function(std::shared_ptr<SyncUser> user, const std::string& name, const bson::BsonArray& args_bson,
                       std::function<void(util::Optional<AppError>, util::Optional<T>)> completion_block)
    {
        call_function(user, name, args_bson, util::none,
                      [completion_block](util::Optional<AppError> error, util::Optional<bson::Bson> value) {
                          if (value) {
                              return completion_block(error, util::some<T>(static_cast<T>(*value)));
                          }

                          return completion_block(error, util::none);
                      });
    }

    template <typename T>
    void call_function(const std::string& name, const bson::BsonArray& args_bson,
                       std::function<void(util::Optional<AppError>, util::Optional<T>)> completion_block)
    {
        call_function(current_user(), name, args_bson, completion_block);
    }

    // NOTE: only sets "Accept: text/event-stream" header. If you use an API that sets that but doesn't support
    // setting other headers (eg. EventSource() in JS), you can ignore the headers field on the request.
    Request make_streaming_request(std::shared_ptr<SyncUser> user, const std::string& name,
                                   const bson::BsonArray& args_bson,
                                   const util::Optional<std::string>& service_name) const;

    // MARK: Push notification client
    PushClient push_notification_client(const std::string& service_name);

    static void clear_cached_apps();

private:
    friend class Internal;
    friend class OnlyForTesting;

    Config m_config;
    mutable std::unique_ptr<std::mutex> m_route_mutex = std::make_unique<std::mutex>();
    std::string m_base_url;
    std::string m_base_route;
    std::string m_app_route;
    std::string m_auth_route;
    uint64_t m_request_timeout_ms;
    std::shared_ptr<SyncManager> m_sync_manager;

    /// Refreshes the access token for a specified `SyncUser`
    /// @param completion_block Passes an error should one occur.
    void refresh_access_token(std::shared_ptr<SyncUser> sync_user,
                              std::function<void(util::Optional<AppError>)> completion_block);


    /// Checks if an auth failure has taken place and if so it will attempt to refresh the
    /// access token and then perform the orginal request again with the new access token
    /// @param error The error to check for auth failures
    /// @param response The original response to pass back should this not be an auth error
    /// @param request The request to perform
    /// @param completion_block returns the original response in the case it is not an auth error, or if a failure
    /// occurs, if the refresh was a success the newly attempted response will be passed back
    void handle_auth_failure(const AppError& error, const Response& response, Request request,
                             std::shared_ptr<SyncUser> sync_user, std::function<void(Response)> completion_block);

    std::string url_for_path(const std::string& path) const override;

    void init_app_metadata(std::function<void(util::Optional<AppError>, util::Optional<Response>)> completion_block);

    /// Performs a request to the Stitch server. This request does not contain authentication state.
    /// @param request The request to be performed
    /// @param completion_block Returns the response from the server
    void do_request(Request request, std::function<void(Response)> completion_block);

    /// Performs an authenticated request to the Stitch server, using the current authentication state
    /// @param request The request to be performed
    /// @param completion_block Returns the response from the server
    void do_authenticated_request(Request request, std::shared_ptr<SyncUser> sync_user,
                                  std::function<void(Response)> completion_block) override;


    /// Gets the social profile for a `SyncUser`
    /// @param completion_block Callback will pass the `SyncUser` with the social profile details
    void get_profile(std::shared_ptr<SyncUser> sync_user,
                     std::function<void(std::shared_ptr<SyncUser>, util::Optional<AppError>)> completion_block);

    /// Log in a user and asynchronously retrieve a user object.
    /// If the log in completes successfully, the completion block will be called, and a
    /// `SyncUser` representing the logged-in user will be passed to it. This user object
    /// can be used to open `Realm`s and retrieve `SyncSession`s. Otherwise, the
    /// completion block will be called with an error.
    ///
    /// @param credentials A `SyncCredentials` object representing the user to log in.
    /// @param linking_user A `SyncUser` you want to link these credentials too
    /// @param completion_block A callback block to be invoked once the log in completes.
    void log_in_with_credentials(
        const AppCredentials& credentials, const std::shared_ptr<SyncUser> linking_user,
        std::function<void(std::shared_ptr<SyncUser>, util::Optional<AppError>)> completion_block);

    /// Provides MongoDB Realm Cloud with metadata related to the users session
    void attach_auth_options(bson::BsonDocument& body);

    std::string function_call_url_path() const;

    void configure(const SyncClientConfig& sync_client_config);
};

// MARK: Provider client templates
template <>
App::UsernamePasswordProviderClient App::provider_client<App::UsernamePasswordProviderClient>();
template <>
App::UserAPIKeyProviderClient App::provider_client<App::UserAPIKeyProviderClient>();

} // namespace app
} // namespace realm

#endif /* REALM_APP_HPP */
