/*************************************************************************
 *
 * Copyright 2019 Realm Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 **************************************************************************/

#ifndef REALM_DECIMAL_HPP
#define REALM_DECIMAL_HPP

#include <realm/string_data.hpp>

#include <string>
#include <cstring>

#include "null.hpp"

namespace realm {

class Decimal128 {
public:
    struct Bid64 {
        Bid64(uint64_t x)
            : w(x)
        {
        }
        uint64_t w;
    };
    struct Bid128 {
        uint64_t w[2];
    };
    Decimal128();
    explicit Decimal128(int64_t);
    explicit Decimal128(uint64_t);
    explicit Decimal128(int);
    explicit Decimal128(double);
    Decimal128(Bid128 coefficient, int exponent, bool sign);
    explicit Decimal128(Bid64);
    explicit Decimal128(StringData);
    explicit Decimal128(Bid128 val)
    {
        m_value = val;
    }
    Decimal128(null) noexcept;
    static Decimal128 nan(const char*);
    static bool is_valid_str(StringData) noexcept;

    bool is_null() const;
    bool is_nan() const;

    bool to_int(int64_t& i) const;

    bool operator==(const Decimal128& rhs) const;
    bool operator!=(const Decimal128& rhs) const;
    bool operator<(const Decimal128& rhs) const;
    bool operator>(const Decimal128& rhs) const;
    bool operator<=(const Decimal128& rhs) const;
    bool operator>=(const Decimal128& rhs) const;

    int compare(const Decimal128& rhs) const;

    Decimal128 operator*(int64_t mul) const;
    Decimal128 operator*(size_t mul) const;
    Decimal128 operator*(int mul) const;
    Decimal128 operator*(Decimal128 mul) const;
    Decimal128& operator*=(Decimal128 mul)
    {
        return *this = *this * mul;
    }
    Decimal128 operator/(int64_t div) const;
    Decimal128 operator/(size_t div) const;
    Decimal128 operator/(int div) const;
    Decimal128 operator/(Decimal128 div) const;
    Decimal128& operator/=(Decimal128 div)
    {
        return *this = *this / div;
    }
    Decimal128& operator+=(Decimal128);
    Decimal128 operator+(Decimal128 rhs) const
    {
        auto ret(*this);
        ret += rhs;
        return ret;
    }
    Decimal128& operator-=(Decimal128);
    Decimal128 operator-(Decimal128 rhs) const
    {
        auto ret(*this);
        ret -= rhs;
        return ret;
    }

    std::string to_string() const;
    Bid64 to_bid64() const;
    const Bid128* raw() const
    {
        return &m_value;
    }
    Bid128* raw()
    {
        return &m_value;
    }
    void unpack(Bid128& coefficient, int& exponent, bool& sign) const noexcept;

private:
    Bid128 m_value;

    void from_int64_t(int64_t val);
};

inline std::ostream& operator<<(std::ostream& ostr, const Decimal128& id)
{
    ostr << id.to_string();
    return ostr;
}

} // namespace realm

namespace std {
template <>
struct numeric_limits<realm::Decimal128> {
    static constexpr bool is_integer = false;
    static realm::Decimal128 lowest() noexcept
    {
        return realm::Decimal128("-Inf");
    }
    static realm::Decimal128 max() noexcept
    {
        return realm::Decimal128("+Inf");
    }
};

template <>
struct hash<realm::Decimal128> {
    size_t operator()(const realm::Decimal128& d) const noexcept
    {
        return static_cast<size_t>(d.raw()->w[0] ^ d.raw()->w[1]);
    }
};
} // namespace std

#endif /* REALM_DECIMAL_HPP */
