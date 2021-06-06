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

#ifndef PUSH_CLIENT_HPP
#define PUSH_CLIENT_HPP

#include <realm/object-store/sync/auth_request_client.hpp>
#include <realm/object-store/sync/app_service_client.hpp>
#include <realm/util/optional.hpp>
#include <string>
#include <map>

namespace realm {
namespace app {

class PushClient {
public:
    PushClient(const std::string& service_name, const std::string& app_id, const uint64_t timeout_ms,
               std::shared_ptr<AuthRequestClient> auth_request_client)
        : m_service_name(service_name)
        , m_app_id(app_id)
        , m_timeout_ms(timeout_ms)
        , m_auth_request_client(auth_request_client)
    {
    }

    ~PushClient() = default;
    PushClient(const PushClient&) = default;
    PushClient(PushClient&&) = default;
    PushClient& operator=(const PushClient&) = default;
    PushClient& operator=(PushClient&&) = default;


    /// Register a device for push notifications.
    /// @param registration_token GCM registration token for the device.
    /// @param sync_user The sync user requesting push registration.
    /// @param completion_block An error will be returned should something go wrong.
    void register_device(const std::string& registration_token, std::shared_ptr<SyncUser> sync_user,
                         std::function<void(util::Optional<AppError>)> completion_block);


    /// Deregister a device for push notificatons, no token or device id needs to be passed
    /// as it is linked to the user in MongoDB Realm Cloud.
    /// @param sync_user The sync user requesting push degistration.
    /// @param completion_block An error will be returned should something go wrong.
    void deregister_device(std::shared_ptr<SyncUser> sync_user,
                           std::function<void(util::Optional<AppError>)> completion_block);

private:
    friend class App;

    std::string m_service_name;
    std::string m_app_id;
    uint64_t m_timeout_ms;
    std::shared_ptr<AuthRequestClient> m_auth_request_client;
};

} // namespace app
} // namespace realm

#endif /* PUSH_CLIENT_HPP */
