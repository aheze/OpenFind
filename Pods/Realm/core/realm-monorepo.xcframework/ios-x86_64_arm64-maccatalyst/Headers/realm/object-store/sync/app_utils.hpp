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


#ifndef APP_UTILS_HPP
#define APP_UTILS_HPP

#include <realm/object-store/sync/generic_network_transport.hpp>
#include <realm/object-store/sync/auth_request_client.hpp>
#include <realm/util/optional.hpp>
#include <string>

namespace realm {
namespace app {

class AppUtils {
public:
    static util::Optional<AppError> check_for_errors(const Response& response);
};
} // namespace app
} // namespace realm

#endif /* APP_UTILS_HPP */
