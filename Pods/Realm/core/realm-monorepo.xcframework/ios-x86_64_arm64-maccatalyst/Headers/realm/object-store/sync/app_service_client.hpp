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


#ifndef APP_SERVICE_CLIENT_HPP
#define APP_SERVICE_CLIENT_HPP

#include <realm/object-store/sync/generic_network_transport.hpp>
#include <realm/object-store/sync/auth_request_client.hpp>
#include <realm/util/optional.hpp>
#include <string>

namespace realm {
namespace app {

/// A class providing the core functionality necessary to make authenticated function call requests for a particular
/// Stitch service.
class AppServiceClient {
public:
    virtual ~AppServiceClient() = default;

    /// Calls the Realm Cloud function with the provided name and arguments.
    /// @param user The sync user to perform this request.
    /// @param name The name of the Realm Cloud function to be called.
    /// @param args_bson The `BSONArray` of arguments to be provided to the function.
    /// @param service_name The name of the service, this is optional.
    /// @param completion_block Returns the result from the intended call, will return an Optional AppError is an
    /// error is thrown and bson if successful
    virtual void
    call_function(std::shared_ptr<SyncUser> user, const std::string& name, const bson::BsonArray& args_bson,
                  const util::Optional<std::string>& service_name,
                  std::function<void(util::Optional<AppError>, util::Optional<bson::Bson>)> completion_block) = 0;

    /// Calls the Realm Cloud function with the provided name and arguments.
    /// @param user The sync user to perform this request.
    /// @param name The name of the Realm Cloud function to be called.
    /// @param args_bson The `BSONArray` of arguments to be provided to the function.
    /// @param completion_block Returns the result from the intended call, will return an Optional AppError is an
    /// error is thrown and bson if successful
    virtual void
    call_function(std::shared_ptr<SyncUser> user, const std::string& name, const bson::BsonArray& args_bson,
                  std::function<void(util::Optional<AppError>, util::Optional<bson::Bson>)> completion_block) = 0;

    /// Calls the Realm Cloud function with the provided name and arguments.
    /// This will use the current logged in user to perform the request
    /// @param name The name of the Realm Cloud function to be called.
    /// @param args_bson The `BSONArray` of arguments to be provided to the function.
    /// @param service_name The name of the service, this is optional.
    /// @param completion_block Returns the result from the intended call, will return an Optional AppError is an
    /// error is thrown and bson if successful
    virtual void
    call_function(const std::string& name, const bson::BsonArray& args_bson,
                  const util::Optional<std::string>& service_name,
                  std::function<void(util::Optional<AppError>, util::Optional<bson::Bson>)> completion_block) = 0;

    /// Calls the Realm Cloud function with the provided name and arguments.
    /// This will use the current logged in user to perform the request
    /// @param name The name of the Realm Cloud function to be called.
    /// @param args_bson The `BSONArray` of arguments to be provided to the function.
    /// @param completion_block Returns the result from the intended call, will return an Optional AppError is an
    /// error is thrown and bson if successful
    virtual void
    call_function(const std::string& name, const bson::BsonArray& args_bson,
                  std::function<void(util::Optional<AppError>, util::Optional<bson::Bson>)> completion_block) = 0;
};

} // namespace app
} // namespace realm

#endif /* APP_SERVICE_CLIENT_HPP */
