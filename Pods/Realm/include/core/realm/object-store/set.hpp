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

#ifndef REALM_OS_SET_HPP
#define REALM_OS_SET_HPP

#include <realm/object-store/collection_notifications.hpp>
#include <realm/object-store/impl/collection_notifier.hpp>

#include <realm/object-store/object.hpp>
#include <realm/object-store/property.hpp>
#include <realm/object-store/results.hpp>

#include <realm/set.hpp>

namespace realm {

namespace _impl {
class SetNotifier;
}

namespace object_store {

class Set : public Collection {
public:
    Set() noexcept;
    Set(std::shared_ptr<Realm> r, const Obj& parent_obj, ColKey col);
    Set(std::shared_ptr<Realm> r, const realm::SetBase& set);
    ~Set();

    Set(const Set&);
    Set& operator=(const Set&);
    Set(Set&&);
    Set& operator=(Set&&);

    Query get_query() const;

    template <class T>
    size_t find(const T&) const;
    template <class T>
    std::pair<size_t, bool> insert(T);
    template <class T>
    std::pair<size_t, bool> remove(const T&);

    template <class T, class Context>
    size_t find(Context&, const T&) const;

    // Find the index in the Set of the first row matching the query
    size_t find(Query&& query) const;

    template <class T, class Context>
    std::pair<size_t, bool> insert(Context&, T&& value, CreatePolicy = CreatePolicy::SetLink);
    template <class T, class Context>
    std::pair<size_t, bool> remove(Context&, const T&);

    std::pair<size_t, bool> insert_any(Mixed value);
    Mixed get_any(size_t ndx) const final;
    std::pair<size_t, bool> remove_any(Mixed value);
    size_t find_any(Mixed value) const final;

    void remove_all();
    void delete_all();

    // Replace the values in this set with the values from an enumerable object
    template <typename T, typename Context>
    void assign(Context&, T&& value, CreatePolicy = CreatePolicy::SetLink);

    template <typename Context>
    auto get(Context&, size_t row_ndx) const;
    template <typename T = Obj>
    T get(size_t row_ndx) const;

    Results sort(SortDescriptor order) const;
    Results sort(const std::vector<std::pair<std::string, bool>>& keypaths) const;
    Results filter(Query q) const;

    Results snapshot() const;

    Set freeze(const std::shared_ptr<Realm>& realm) const;

    // Get the min/max/average/sum of the given column
    // All but sum() returns none when there are zero matching rows
    // sum() returns 0,
    // Throws UnsupportedColumnTypeException for sum/average on timestamp or non-numeric column
    // Throws OutOfBoundsIndexException for an out-of-bounds column
    util::Optional<Mixed> max(ColKey column = {}) const;
    util::Optional<Mixed> min(ColKey column = {}) const;
    util::Optional<Mixed> average(ColKey column = {}) const;
    Mixed sum(ColKey column = {}) const;

    bool is_subset_of(const Set& rhs) const;
    bool is_strict_subset_of(const Set& rhs) const;
    bool is_superset_of(const Set& rhs) const;
    bool is_strict_superset_of(const Set& rhs) const;
    bool intersects(const Set& rhs) const;
    bool set_equals(const Set& rhs) const;

    void assign_intersection(const Set& rhs);
    void assign_union(const Set& rhs);
    void assign_difference(const Set& rhs);

    bool operator==(const Set& rhs) const noexcept;

    NotificationToken add_notification_callback(CollectionChangeCallback cb) &;

    struct InvalidEmbeddedOperationException : std::logic_error {
        InvalidEmbeddedOperationException()
            : std::logic_error("Cannot add an embedded object to a Set.")
        {
        }
    };

private:
    _impl::CollectionNotifier::Handle<_impl::SetNotifier> m_notifier;
    std::shared_ptr<realm::SetBase> m_set_base;

    ConstTableRef get_target_table() const;

    template <class Fn>
    auto dispatch(Fn&&) const;
    template <class T>
    auto& as() const;

    friend struct std::hash<Set>;
};

template <class Fn>
auto Set::dispatch(Fn&& fn) const
{
    verify_attached();
    return switch_on_type(get_type(), std::forward<Fn>(fn));
}

template <class T>
auto& Set::as() const
{
    REALM_ASSERT(dynamic_cast<realm::Set<T>*>(m_set_base.get()));
    return static_cast<realm::Set<T>&>(*m_set_base);
}

template <>
inline auto& Set::as<Obj>() const
{
    REALM_ASSERT(dynamic_cast<LnkSet*>(&*m_set_base));
    return static_cast<LnkSet&>(*m_set_base);
}

template <>
inline auto& Set::as<ObjKey>() const
{
    REALM_ASSERT(dynamic_cast<LnkSet*>(&*m_set_base));
    return static_cast<LnkSet&>(*m_set_base);
}

template <class T, class Context>
size_t Set::find(Context& ctx, const T& value) const
{
    return dispatch([&](auto t) {
        return this->find(ctx.template unbox<std::decay_t<decltype(*t)>>(value, CreatePolicy::Skip));
    });
}

template <typename Context>
auto Set::get(Context& ctx, size_t row_ndx) const
{
    return dispatch([&](auto t) {
        return ctx.box(this->get<std::decay_t<decltype(*t)>>(row_ndx));
    });
}

template <class T, class Context>
std::pair<size_t, bool> Set::insert(Context& ctx, T&& value, CreatePolicy policy)
{
    return dispatch([&](auto t) {
        return this->insert(ctx.template unbox<std::decay_t<decltype(*t)>>(value, policy));
    });
}

template <class T, class Context>
std::pair<size_t, bool> Set::remove(Context& ctx, const T& value)
{
    return dispatch([&](auto t) {
        return this->remove(ctx.template unbox<std::decay_t<decltype(*t)>>(value));
    });
}

template <typename T, typename Context>
void Set::assign(Context& ctx, T&& values, CreatePolicy policy)
{
    if (ctx.is_same_set(*this, values))
        return;

    if (ctx.is_null(values)) {
        remove_all();
        return;
    }

    if (!policy.diff)
        remove_all();

    ctx.enumerate_collection(values, [&](auto&& element) {
        this->insert(ctx, element, policy);
    });
}

} // namespace object_store
} // namespace realm

namespace std {
template <>
struct hash<realm::object_store::Set> {
    size_t operator()(realm::object_store::Set const&) const;
};
} // namespace std

#endif // REALM_OS_SET_HPP
