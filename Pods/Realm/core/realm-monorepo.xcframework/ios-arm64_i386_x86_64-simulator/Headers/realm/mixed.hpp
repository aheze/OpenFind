/*************************************************************************
 *
 * Copyright 2016 Realm Inc.
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

#ifndef REALM_MIXED_HPP
#define REALM_MIXED_HPP

#include <cstdint> // int64_t - not part of C++03, not even required by C++11 (see C++11 section 18.4.1)

#include <cstddef> // size_t
#include <cstring>

#include <realm/keys.hpp>
#include <realm/binary_data.hpp>
#include <realm/data_type.hpp>
#include <realm/string_data.hpp>
#include <realm/timestamp.hpp>
#include <realm/decimal128.hpp>
#include <realm/object_id.hpp>
#include <realm/uuid.hpp>
#include <realm/util/assert.hpp>
#include <realm/utilities.hpp>

namespace realm {


/// This class represents a polymorphic Realm value.
///
/// At any particular moment an instance of this class stores a
/// definite value of a definite type. If, for instance, that is an
/// integer value, you may call get<int64_t>() to extract that value. You
/// may call get_type() to discover what type of value is currently
/// stored. Calling get<int64_t>() on an instance that does not store an
/// integer, has undefined behavior, and likewise for all the other
/// types that can be stored.
///
/// It is crucial to understand that the act of extracting a value of
/// a particular type requires definite knowledge about the stored
/// type. Calling a getter method for any particular type, that is not
/// the same type as the stored value, has undefined behavior.
///
/// While values of numeric types are contained directly in a Mixed
/// instance, character and binary data are merely referenced. A Mixed
/// instance never owns the referenced data, nor does it in any other
/// way attempt to manage its lifetime.
///
/// For compatibility with C style strings, when a string (character
/// data) is stored in a Realm database, it is always followed by a
/// terminating null character. This is also true when strings are
/// stored in a mixed type column. This means that in the following
/// code, if the 'mixed' value of the 8th row stores a string, then \c
/// c_str will always point to a null-terminated string:
///
/// \code{.cpp}
///
///   const char* c_str = my_table[7].mixed.data(); // Always null-terminated
///
/// \endcode
///
/// Note that this assumption does not hold in general for strings in
/// instances of Mixed. Indeed there is nothing stopping you from
/// constructing a new Mixed instance that refers to a string without
/// a terminating null character.
///
/// At the present time no soultion has been found that would allow
/// for a Mixed instance to directly store a reference to a table. The
/// problem is roughly as follows: From most points of view, the
/// desirable thing to do, would be to store the table reference in a
/// Mixed instance as a plain pointer without any ownership
/// semantics. This would have no negative impact on the performance
/// of copying and destroying Mixed instances, and it would serve just
/// fine for passing a table as argument when setting the value of an
/// entry in a mixed column. In that case a copy of the referenced
/// table would be inserted into the mixed column.
///
/// On the other hand, when retrieving a table reference from a mixed
/// column, storing it as a plain pointer in a Mixed instance is no
/// longer an acceptable option. The complex rules for managing the
/// lifetime of a Table instance, that represents a subtable,
/// necessitates the use of a "smart pointer" such as
/// TableRef. Enhancing the Mixed class to be able to act as a
/// TableRef would be possible, but would also lead to several new
/// problems. One problem is the risk of a Mixed instance outliving a
/// stack allocated Table instance that it references. This would be a
/// fatal error. Another problem is the impact that the nontrivial
/// table reference has on the performance of copying and destroying
/// Mixed instances.
///
/// \sa StringData
class Mixed {
public:
    Mixed() noexcept
        : m_type(0)
    {
    }

    Mixed(util::None) noexcept
        : Mixed()
    {
    }

    Mixed(realm::null) noexcept
        : Mixed()
    {
    }

    Mixed(int i) noexcept
        : Mixed(int64_t(i))
    {
    }

    Mixed(int64_t) noexcept;
    Mixed(bool) noexcept;
    Mixed(float) noexcept;
    Mixed(double) noexcept;
    Mixed(util::Optional<int64_t>) noexcept;
    Mixed(util::Optional<bool>) noexcept;
    Mixed(util::Optional<float>) noexcept;
    Mixed(util::Optional<double>) noexcept;
    Mixed(StringData) noexcept;
    Mixed(BinaryData) noexcept;
    Mixed(Timestamp) noexcept;
    Mixed(Decimal128);
    Mixed(ObjectId) noexcept;
    Mixed(util::Optional<ObjectId>) noexcept;
    Mixed(ObjKey) noexcept;
    Mixed(ObjLink) noexcept;
    Mixed(UUID) noexcept;
    Mixed(util::Optional<UUID>) noexcept;
    Mixed(const Obj&) noexcept;

    // These are shortcuts for Mixed(StringData(c_str)), and are
    // needed to avoid unwanted implicit conversion of char* to bool.
    Mixed(char* c_str) noexcept
        : Mixed(StringData(c_str))
    {
    }
    Mixed(const char* c_str) noexcept
        : Mixed(StringData(c_str))
    {
    }
    Mixed(const std::string& s) noexcept
        : Mixed(StringData(s))
    {
    }

    ~Mixed() noexcept
    {
    }

    DataType get_type() const noexcept
    {
        REALM_ASSERT(m_type);
        return DataType(m_type - 1);
    }

    static bool types_are_comparable(const Mixed& l, const Mixed& r);
    static bool data_types_are_comparable(DataType l_type, DataType r_type);

    template <class T>
    T get() const noexcept;

    template <class T>
    T export_to_type() const noexcept;

    // These functions are kept to be backwards compatible
    int64_t get_int() const;
    bool get_bool() const;
    float get_float() const;
    double get_double() const;
    StringData get_string() const;
    BinaryData get_binary() const;
    Timestamp get_timestamp() const;
    Decimal128 get_decimal() const;
    ObjectId get_object_id() const;
    UUID get_uuid() const;
    ObjLink get_link() const;

    bool is_null() const;
    bool is_unresolved_link() const;
    int compare(const Mixed& b) const;
    bool operator==(const Mixed& other) const
    {
        return compare(other) == 0;
    }
    bool operator!=(const Mixed& other) const
    {
        return compare(other) != 0;
    }
    bool operator<(const Mixed& other) const
    {
        return compare(other) < 0;
    }
    bool operator>(const Mixed& other) const
    {
        return compare(other) > 0;
    }
    bool operator<=(const Mixed& other) const
    {
        return compare(other) <= 0;
    }
    bool operator>=(const Mixed& other) const
    {
        return compare(other) >= 0;
    }
    size_t hash() const;

protected:
    friend std::ostream& operator<<(std::ostream& out, const Mixed& m);

    uint32_t m_type;
    union {
        int64_t int_val;
        bool bool_val;
        float float_val;
        double double_val;
        StringData string_val;
        BinaryData binary_val;
        Timestamp date_val;
        ObjectId id_val;
        Decimal128 decimal_val;
        ObjLink link_val;
        UUID uuid_val;
    };
};

// Implementation:

inline Mixed::Mixed(int64_t v) noexcept
{
    m_type = int(type_Int) + 1;
    int_val = v;
}

inline Mixed::Mixed(bool v) noexcept
{
    m_type = int(type_Bool) + 1;
    bool_val = v;
}

inline Mixed::Mixed(float v) noexcept
{
    if (null::is_null_float(v)) {
        m_type = 0;
    }
    else {
        m_type = int(type_Float) + 1;
        float_val = v;
    }
}

inline Mixed::Mixed(double v) noexcept
{
    if (null::is_null_float(v)) {
        m_type = 0;
    }
    else {
        m_type = int(type_Double) + 1;
        double_val = v;
    }
}

inline Mixed::Mixed(util::Optional<int64_t> v) noexcept
{
    if (v) {
        m_type = int(type_Int) + 1;
        int_val = *v;
    }
    else {
        m_type = 0;
    }
}

inline Mixed::Mixed(util::Optional<bool> v) noexcept
{
    if (v) {
        m_type = int(type_Bool) + 1;
        bool_val = *v;
    }
    else {
        m_type = 0;
    }
}

inline Mixed::Mixed(util::Optional<float> v) noexcept
{
    if (v && !null::is_null_float(*v)) {
        m_type = int(type_Float) + 1;
        float_val = *v;
    }
    else {
        m_type = 0;
    }
}

inline Mixed::Mixed(util::Optional<double> v) noexcept
{
    if (v && !null::is_null_float(*v)) {
        m_type = int(type_Double) + 1;
        double_val = *v;
    }
    else {
        m_type = 0;
    }
}

inline Mixed::Mixed(util::Optional<ObjectId> v) noexcept
{
    if (v) {
        m_type = int(type_ObjectId) + 1;
        id_val = *v;
    }
    else {
        m_type = 0;
    }
}

inline Mixed::Mixed(util::Optional<UUID> v) noexcept
{
    if (v) {
        m_type = int(type_UUID) + 1;
        uuid_val = *v;
    }
    else {
        m_type = 0;
    }
}

inline Mixed::Mixed(StringData v) noexcept
{
    if (!v.is_null()) {
        m_type = int(type_String) + 1;
        string_val = v;
    }
    else {
        m_type = 0;
    }
}

inline Mixed::Mixed(BinaryData v) noexcept
{
    if (!v.is_null()) {
        m_type = int(type_Binary) + 1;
        binary_val = v;
    }
    else {
        m_type = 0;
    }
}

inline Mixed::Mixed(Timestamp v) noexcept
{
    if (!v.is_null()) {
        m_type = int(type_Timestamp) + 1;
        date_val = v;
    }
    else {
        m_type = 0;
    }
}

inline Mixed::Mixed(Decimal128 v)
{
    if (!v.is_null()) {
        m_type = int(type_Decimal) + 1;
        decimal_val = v;
    }
    else {
        m_type = 0;
    }
}

inline Mixed::Mixed(ObjectId v) noexcept
{
    m_type = int(type_ObjectId) + 1;
    id_val = v;
}

inline Mixed::Mixed(UUID v) noexcept
{
    m_type = int(type_UUID) + 1;
    uuid_val = v;
}

inline Mixed::Mixed(ObjKey v) noexcept
{
    if (v) {
        m_type = int(type_Link) + 1;
        int_val = v.value;
    }
    else {
        m_type = 0;
    }
}

inline Mixed::Mixed(ObjLink v) noexcept
{
    if (v) {
        m_type = int(type_TypedLink) + 1;
        link_val = v;
    }
    else {
        m_type = 0;
    }
}

template <>
inline null Mixed::get<null>() const noexcept
{
    REALM_ASSERT(m_type == 0);
    return {};
}

template <>
inline int64_t Mixed::get<int64_t>() const noexcept
{
    REALM_ASSERT(get_type() == type_Int);
    return int_val;
}

template <>
inline int Mixed::get<int>() const noexcept
{
    REALM_ASSERT(get_type() == type_Int);
    return int(int_val);
}

inline int64_t Mixed::get_int() const
{
    return get<int64_t>();
}

template <>
inline bool Mixed::get<bool>() const noexcept
{
    REALM_ASSERT(get_type() == type_Bool);
    return bool_val;
}

inline bool Mixed::get_bool() const
{
    return get<bool>();
}

template <>
inline float Mixed::get<float>() const noexcept
{
    REALM_ASSERT(get_type() == type_Float);
    return float_val;
}

inline float Mixed::get_float() const
{
    return get<float>();
}

template <>
inline double Mixed::get<double>() const noexcept
{
    REALM_ASSERT(get_type() == type_Double);
    return double_val;
}

inline double Mixed::get_double() const
{
    return get<double>();
}

template <>
inline StringData Mixed::get<StringData>() const noexcept
{
    if (is_null())
        return StringData();
    REALM_ASSERT(get_type() == type_String);
    return string_val;
}

inline StringData Mixed::get_string() const
{
    return get<StringData>();
}

template <>
inline BinaryData Mixed::get<BinaryData>() const noexcept
{
    if (is_null())
        return BinaryData();
    if (get_type() == type_Binary) {
        return binary_val;
    }
    REALM_ASSERT(get_type() == type_String);
    return BinaryData(string_val.data(), string_val.size());
}

inline BinaryData Mixed::get_binary() const
{
    return get<BinaryData>();
}

template <>
inline Timestamp Mixed::get<Timestamp>() const noexcept
{
    REALM_ASSERT(get_type() == type_Timestamp);
    return date_val;
}

inline Timestamp Mixed::get_timestamp() const
{
    return get<Timestamp>();
}

template <>
inline Decimal128 Mixed::get<Decimal128>() const noexcept
{
    REALM_ASSERT(get_type() == type_Decimal);
    return decimal_val;
}

inline Decimal128 Mixed::get_decimal() const
{
    return get<Decimal128>();
}

template <>
inline ObjectId Mixed::get<ObjectId>() const noexcept
{
    REALM_ASSERT(get_type() == type_ObjectId);
    return id_val;
}

inline ObjectId Mixed::get_object_id() const
{
    return get<ObjectId>();
}

template <>
inline UUID Mixed::get<UUID>() const noexcept
{
    REALM_ASSERT(get_type() == type_UUID);
    return uuid_val;
}

inline UUID Mixed::get_uuid() const
{
    return get<UUID>();
}

template <>
inline ObjKey Mixed::get<ObjKey>() const noexcept
{
    REALM_ASSERT(get_type() == type_Link);
    return ObjKey(int_val);
}

template <>
inline ObjLink Mixed::get<ObjLink>() const noexcept
{
    REALM_ASSERT(get_type() == type_TypedLink);
    return link_val;
}

template <>
inline Mixed Mixed::get<Mixed>() const noexcept
{
    return *this;
}

inline ObjLink Mixed::get_link() const
{
    return get<ObjLink>();
}

inline bool Mixed::is_null() const
{
    return (m_type == 0);
}

inline bool Mixed::is_unresolved_link() const
{
    if (is_null()) {
        return false;
    }
    else if (get_type() == type_TypedLink) {
        return get<ObjLink>().is_unresolved();
    }
    else if (get_type() == type_Link) {
        return get<ObjKey>().is_unresolved();
    }
    return false;
}

std::ostream& operator<<(std::ostream& out, const Mixed& m);

} // namespace realm

#endif // REALM_MIXED_HPP
