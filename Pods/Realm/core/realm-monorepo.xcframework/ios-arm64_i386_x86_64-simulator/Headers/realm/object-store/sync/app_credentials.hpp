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

#ifndef REALM_APP_CREDENTIALS_HPP
#define REALM_APP_CREDENTIALS_HPP

#include <realm/object-store/util/tagged_string.hpp>

#include <functional>
#include <string>

namespace realm {
namespace bson {
class Bson;
template <typename>
class IndexedMap;
using BsonDocument = IndexedMap<Bson>;
} // namespace bson
namespace app {

typedef std::string IdentityProvider;
typedef std::string AppCredentialsToken;

using AuthCode = util::TaggedString<class AuthCodeTag>;
using IdToken = util::TaggedString<class IdTokenTag>;

// The username/password identity provider. User accounts are handled by the Realm Object Server directly without the
// involvement of a third-party identity provider.
extern IdentityProvider const IdentityProviderUsernamePassword;

// A Facebook account as an identity provider.
extern IdentityProvider const IdentityProviderFacebook;

// A Google account as an identity provider.
extern IdentityProvider const IdentityProviderGoogle;

// A JSON Web Token as an identity provider.
extern IdentityProvider const IdentityProviderCustom;

// An Anonymous account as an identity provider.
extern IdentityProvider const IdentityProviderAnonymous;

// A Google account as an identity provider.
extern IdentityProvider const IdentityProviderApple;

// The `FunctionCredential` can be used to log in using
// the [Function Authentication Provider](https://docs.mongodb.com/stitch/authentication/custom-function/).
extern IdentityProvider const IdentityProviderFunction;

// A credential which can be used to log in as a Stitch user
// using the User API Key authentication provider.
extern IdentityProvider const IdentityProviderUserAPIKey;

// A credential which can be used to log in as a Stitch user
// using the Server API Key authentication provider.
extern IdentityProvider const IdentityProviderServerAPIKey;

enum class AuthProvider {
    ANONYMOUS,
    FACEBOOK,
    GOOGLE,
    APPLE,
    CUSTOM,
    USERNAME_PASSWORD,
    FUNCTION,
    USER_API_KEY,
    SERVER_API_KEY
};

IdentityProvider provider_type_from_enum(AuthProvider provider);

// Opaque credentials representing a specific Realm Object Server user.
struct AppCredentials {
    // Construct and return credentials from a Facebook account token.
    static AppCredentials facebook(const AppCredentialsToken access_token);

    // Construct and return anonymous credentials
    static AppCredentials anonymous();

    // Construct and return credentials from an Apple account token.
    static AppCredentials apple(const AppCredentialsToken id_token);

    // Construct and return credentials from a google account token.
    static AppCredentials google(AuthCode&& id_token);

    // Construct and return credentials from a google account token.
    static AppCredentials google(IdToken&& id_token);

    // Construct and return credentials from a jwt token.
    static AppCredentials custom(const AppCredentialsToken token);

    // Construct and return credentials from a username and password.
    static AppCredentials username_password(std::string username, std::string password);

    // Construct and return credentials with the payload.
    // The payload is a MongoDB document as json
    static AppCredentials function(const bson::BsonDocument& payload);

    // Construct and return credentials with the payload.
    // The payload is a MongoDB document as json
    static AppCredentials function(const std::string& serialized_payload);

    // Construct and return credentials with the user api key.
    static AppCredentials user_api_key(std::string api_key);

    // Construct and return credentials with the server api key.
    static AppCredentials server_api_key(std::string api_key);


    // The provider of the credential
    AuthProvider provider() const;
    std::string provider_as_string() const;

    // The serialized payload
    std::string serialize_as_json() const;

    AppCredentials() = default;
    AppCredentials(const AppCredentials&) = default;
    AppCredentials(AppCredentials&&) = default;
    AppCredentials& operator=(AppCredentials const&) = default;
    AppCredentials& operator=(AppCredentials&&) = default;

private:
    AppCredentials(AuthProvider provider, std::function<std::string()> factory);
    // The name of the identity provider which generated the credentials token.
    AuthProvider m_provider;
    std::function<std::string()> m_payload_factory;
};

} // namespace app
} // namespace realm

#endif /* REALM_APP_CREDENTIALS_HPP */
