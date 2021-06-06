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
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

#ifndef REALM_OS_DICTIONARY_HPP_
#define REALM_OS_DICTIONARY_HPP_

#include <realm/object-store/collection.hpp>
#include <realm/object-store/object.hpp>
#include <realm/dictionary.hpp>

namespace realm {
namespace object_store {

class Dictionary : public object_store::Collection {
public:
    using Iterator = realm::Dictionary::Iterator;
    Dictionary() noexcept;
    Dictionary(std::shared_ptr<Realm> r, const Obj& parent_obj, ColKey col);
    Dictionary(std::shared_ptr<Realm> r, const realm::Dictionary& dict);
    ~Dictionary() override;

    bool operator==(const Dictionary& rgt) const noexcept
    {
        return *m_dict == *rgt.m_dict;
    }

    template <typename T>
    void insert(StringData key, T value);
    template <typename T>
    T get(StringData key) const;

    void erase(StringData key)
    {
        verify_in_transaction();
        m_dict->erase(key);
    }
    void remove_all()
    {
        verify_in_transaction();
        m_dict->clear();
    }

    Mixed get_any(StringData key)
    {
        return m_dict->get(key);
    }
    Mixed get_any(size_t ndx) const final
    {
        verify_valid_row(ndx);
        return m_dict->get_any(ndx);
    }
    util::Optional<Mixed> try_get_any(StringData key) const
    {
        return m_dict->try_get(key);
    }
    std::pair<StringData, Mixed> get_pair(size_t ndx) const
    {
        verify_valid_row(ndx);
        auto pair = m_dict->get_pair(ndx);
        return {pair.first.get_string(), pair.second};
    }

    size_t find_any(Mixed value) const final
    {
        return m_dict->find_any(value);
    }
    bool contains(StringData key)
    {
        return m_dict->contains(key);
    }

    template <typename T, typename Context>
    void insert(Context&, StringData key, T&& value, CreatePolicy = CreatePolicy::SetLink);
    template <typename Context>
    auto get(Context&, StringData key) const;

    // Replace the values in this dictionary with the values from an map type object
    template <typename T, typename Context>
    void assign(Context&, T&& value, CreatePolicy = CreatePolicy::SetLink);

    Results snapshot() const;
    Dictionary freeze(const std::shared_ptr<Realm>& realm) const;

    Iterator begin() const
    {
        return m_dict->begin();
    }

    Iterator end() const
    {
        return m_dict->end();
    }

private:
    realm::Dictionary* m_dict;

    template <typename Fn>
    auto dispatch(Fn&&) const;
    Obj get_object(StringData key) const;
};


template <typename Fn>
auto Dictionary::dispatch(Fn&& fn) const
{
    // Similar to "switch_on_type", but without the util::Optional
    // cases. These cases are not supported by Mixed and are not
    // relevant for Dictionary
    // FIXME: use switch_on_type
    verify_attached();
    using PT = PropertyType;
    auto type = get_type();
    switch (type & ~PropertyType::Flags) {
        case PT::Int:
            return fn((int64_t*)0);
        case PT::Bool:
            return fn((bool*)0);
        case PT::Float:
            return fn((float*)0);
        case PT::Double:
            return fn((double*)0);
        case PT::String:
            return fn((StringData*)0);
        case PT::Data:
            return fn((BinaryData*)0);
        case PT::Date:
            return fn((Timestamp*)0);
        case PT::Object:
            return fn((Obj*)0);
        case PT::ObjectId:
            return fn((ObjectId*)0);
        case PT::Decimal:
            return fn((Decimal128*)0);
        case PT::UUID:
            return fn((UUID*)0);
        default:
            REALM_COMPILER_HINT_UNREACHABLE();
    }
}

template <typename T>
void Dictionary::insert(StringData key, T value)
{
    verify_in_transaction();
    m_dict->insert(key, value);
}

template <typename T>
T Dictionary::get(StringData key) const
{
    return m_dict->get(key).get<T>();
}

template <>
inline Obj Dictionary::get<Obj>(StringData key) const
{
    return get_object(key);
}

template <typename T, typename Context>
void Dictionary::insert(Context& ctx, StringData key, T&& value, CreatePolicy policy)
{
    dispatch([&](auto t) {
        this->insert(key, ctx.template unbox<std::decay_t<decltype(*t)>>(value, policy));
    });
}

template <typename Context>
auto Dictionary::get(Context& ctx, StringData key) const
{
    return dispatch([&](auto t) {
        return ctx.box(this->get<std::decay_t<decltype(*t)>>(key));
    });
}

template <typename T, typename Context>
void Dictionary::assign(Context& ctx, T&& values, CreatePolicy policy)
{
    if (ctx.is_same_dictionary(*this, values))
        return;

    if (ctx.is_null(values)) {
        remove_all();
        return;
    }

    if (!policy.diff)
        remove_all();

    ctx.enumerate_dictionary(values, [&](StringData key, auto&& value) {
        if (policy.diff) {
            util::Optional<Mixed> old_value = m_dict->try_get(key);
            auto new_value = ctx.template unbox<Mixed>(value);
            if (!old_value || *old_value != new_value) {
                m_dict->insert(key, new_value);
            }
        }
        else {
            this->insert(ctx, key, value, policy);
        }
    });
    // FIXME: Remove entries not included in the new value
}

} // namespace object_store
} // namespace realm


#endif /* REALM_OS_DICTIONARY_HPP_ */
