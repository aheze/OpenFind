/*************************************************************************
 *
 * Copyright 2020 Realm Inc.
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

#ifndef REALM_SET_HPP
#define REALM_SET_HPP

#include <realm/collection.hpp>
#include <realm/bplustree.hpp>
#include <realm/array_key.hpp>

#include <numeric> // std::iota

namespace realm {

class SetBase : public CollectionBase {
public:
    using CollectionBase::CollectionBase;

    virtual ~SetBase() {}
    virtual SetBasePtr clone() const = 0;
    virtual std::pair<size_t, bool> insert_null() = 0;
    virtual std::pair<size_t, bool> erase_null() = 0;
    virtual std::pair<size_t, bool> insert_any(Mixed value) = 0;
    virtual std::pair<size_t, bool> erase_any(Mixed value) = 0;

protected:
    void insert_repl(Replication* repl, size_t index, Mixed value) const;
    void erase_repl(Replication* repl, size_t index, Mixed value) const;
    void clear_repl(Replication* repl) const;
};

template <class T>
class Set final : public CollectionBaseImpl<SetBase> {
public:
    using Base = CollectionBaseImpl<SetBase>;
    using value_type = T;
    using iterator = CollectionIterator<Set<T>>;

    Set() = default;
    Set(const Obj& owner, ColKey col_key);
    Set(const Set& other);
    Set(Set&& other) noexcept;
    Set& operator=(const Set& other);
    Set& operator=(Set&& other) noexcept;
    using Base::operator==;
    using Base::operator!=;

    SetBasePtr clone() const final
    {
        return std::make_unique<Set<T>>(*this);
    }

    T get(size_t ndx) const
    {
        const auto current_size = size();
        if (ndx >= current_size) {
            throw std::out_of_range("Index out of range");
        }
        return m_tree->get(ndx);
    }

    iterator begin() const noexcept
    {
        return iterator{this, 0};
    }

    iterator end() const noexcept
    {
        return iterator{this, size()};
    }

    size_t find_first(const T& value) const
    {
        return find(value);
    }

    template <class Func>
    void find_all(T value, Func&& func) const
    {
        size_t found = find(value);
        if (found != not_found) {
            func(found);
        }
    }

    template <class Rhs>
    bool is_subset_of(const Rhs&) const;

    template <class It1, class It2>
    bool is_subset_of(It1, It2) const;

    template <class Rhs>
    bool is_strict_subset_of(const Rhs&) const;

    template <class It1, class It2>
    bool is_strict_subset_of(It1, It2) const;

    template <class Rhs>
    bool is_superset_of(const Rhs&) const;

    template <class It1, class It2>
    bool is_superset_of(It1, It2) const;

    template <class Rhs>
    bool is_strict_superset_of(const Rhs&) const;

    template <class It1, class It2>
    bool is_strict_superset_of(It1, It2) const;

    template <class Rhs>
    bool intersects(const Rhs&) const;

    template <class It1, class It2>
    bool intersects(It1, It2) const;

    template <class Rhs>
    bool set_equals(const Rhs&) const;

    template <class It1, class It2>
    bool set_equals(It1, It2) const;

    template <class Rhs>
    void assign_union(const Rhs&);

    template <class It1, class It2>
    void assign_union(It1, It2);

    template <class Rhs>
    void assign_intersection(const Rhs&);

    template <class It1, class It2>
    void assign_intersection(It1, It2);

    template <class Rhs>
    void assign_difference(const Rhs&);

    template <class It1, class It2>
    void assign_difference(It1, It2);

    template <class Rhs>
    void assign_symmetric_difference(const Rhs&);

    template <class It1, class It2>
    void assign_symmetric_difference(It1, It2);

    /// Insert a value into the set if it does not already exist, returning the index of the inserted value,
    /// or the index of the already-existing value.
    std::pair<size_t, bool> insert(T value);

    /// Find the index of a value in the set, or `size_t(-1)` if it is not in the set.
    size_t find(T value) const;

    /// Erase an element from the set, returning true if the set contained the element.
    std::pair<size_t, bool> erase(T value);

    // Overriding members of CollectionBase:
    size_t size() const final;
    bool is_null(size_t ndx) const final;
    Mixed get_any(size_t ndx) const final
    {
        return get(ndx);
    }
    void clear() final;
    Mixed min(size_t* return_ndx = nullptr) const final;
    Mixed max(size_t* return_ndx = nullptr) const final;
    Mixed sum(size_t* return_cnt = nullptr) const final;
    Mixed avg(size_t* return_cnt = nullptr) const final;
    std::unique_ptr<CollectionBase> clone_collection() const final
    {
        return std::make_unique<Set<T>>(*this);
    }
    void sort(std::vector<size_t>& indices, bool ascending = true) const final;
    void distinct(std::vector<size_t>& indices, util::Optional<bool> sort_order = util::none) const final;

    // Overriding members of SetBase:
    size_t find_any(Mixed) const final;
    std::pair<size_t, bool> insert_null() final;
    std::pair<size_t, bool> erase_null() final;
    std::pair<size_t, bool> insert_any(Mixed value) final;
    std::pair<size_t, bool> erase_any(Mixed value) final;

    const BPlusTree<T>& get_tree() const
    {
        return *m_tree;
    }

private:
    mutable std::unique_ptr<BPlusTree<T>> m_tree;
    using Base::m_col_key;
    using Base::m_obj;
    using Base::m_valid;

    void create()
    {
        m_tree->create();
        m_valid = true;
    }

    REALM_NOINLINE bool init_from_parent() const final
    {
        m_valid = m_tree->init_from_parent();
        update_content_version();
        return m_valid;
    }

    REALM_NOINLINE void ensure_created()
    {
        if (!m_valid && m_obj.is_valid()) {
            create();
        }
    }
    void do_insert(size_t ndx, T value);
    void do_erase(size_t ndx);

    iterator find_impl(const T& value) const;

    friend class LnkSet;
};

class LnkSet final : public ObjCollectionBase<SetBase> {
public:
    using Base = ObjCollectionBase<SetBase>;
    using value_type = ObjKey;
    using iterator = CollectionIterator<LnkSet>;

    LnkSet() = default;
    LnkSet(const Obj& owner, ColKey col_key)
        : m_set(owner, col_key)
    {
        update_unresolved();
    }

    LnkSet(const LnkSet&) = default;
    LnkSet(LnkSet&&) = default;
    LnkSet& operator=(const LnkSet&) = default;
    LnkSet& operator=(LnkSet&&) = default;
    bool operator==(const LnkSet& other) const;
    bool operator!=(const LnkSet& other) const;

    ObjKey get(size_t ndx) const;
    size_t find(ObjKey) const;
    size_t find_first(ObjKey) const;
    std::pair<size_t, bool> insert(ObjKey);
    std::pair<size_t, bool> erase(ObjKey);

    template <class Rhs>
    void assign_union(const Rhs&);

    template <class It1, class It2>
    void assign_union(It1, It2);

    template <class Rhs>
    void assign_intersection(const Rhs&);

    template <class It1, class It2>
    void assign_intersection(It1, It2);

    template <class Rhs>
    void assign_difference(const Rhs&);

    template <class It1, class It2>
    void assign_difference(It1, It2);

    template <class Rhs>
    void assign_symmetric_difference(const Rhs&);

    template <class It1, class It2>
    void assign_symmetric_difference(It1, It2);

    bool is_subset_of(const LnkSet& rhs) const;
    bool is_strict_subset_of(const LnkSet& rhs) const;
    bool is_superset_of(const LnkSet& rhs) const;
    bool is_strict_superset_of(const LnkSet& rhs) const;
    bool intersects(const LnkSet& rhs) const;

    // Overriding members of CollectionBase:
    using CollectionBase::get_key;
    CollectionBasePtr clone_collection() const
    {
        return clone_linkset();
    }
    size_t size() const final;
    bool is_null(size_t ndx) const final;
    Mixed get_any(size_t ndx) const final;
    void clear() final;
    Mixed min(size_t* return_ndx = nullptr) const final;
    Mixed max(size_t* return_ndx = nullptr) const final;
    Mixed sum(size_t* return_cnt = nullptr) const final;
    Mixed avg(size_t* return_cnt = nullptr) const final;
    void sort(std::vector<size_t>& indices, bool ascending = true) const final;
    void distinct(std::vector<size_t>& indices, util::Optional<bool> sort_order = util::none) const final;
    const Obj& get_obj() const noexcept final;
    bool is_attached() const final;
    bool has_changed() const final;
    ColKey get_col_key() const noexcept final;

    // Overriding members of SetBase:
    SetBasePtr clone() const
    {
        return clone_linkset();
    }
    size_t find_any(Mixed) const final;
    std::pair<size_t, bool> insert_null() final;
    std::pair<size_t, bool> erase_null() final;
    std::pair<size_t, bool> insert_any(Mixed value) final;
    std::pair<size_t, bool> erase_any(Mixed value) final;

    // Overriding members of ObjList:
    bool is_obj_valid(size_t) const noexcept final;
    Obj get_object(size_t ndx) const final;
    ObjKey get_key(size_t ndx) const final;

    // LnkSet interface:

    std::unique_ptr<LnkSet> clone_linkset() const
    {
        // FIXME: The copy constructor requires this.
        update_if_needed();
        return std::make_unique<LnkSet>(*this);
    }

    template <class Func>
    void find_all(ObjKey value, Func&& func) const
    {
        if (value.is_unresolved()) {
            return;
        }

        m_set.find_all(value, [&](size_t ndx) {
            func(real2virtual(ndx));
        });
    }

    TableView get_sorted_view(SortDescriptor order) const;
    TableView get_sorted_view(ColKey column_key, bool ascending = true);
    void remove_target_row(size_t link_ndx);
    void remove_all_target_rows();

    iterator begin() const noexcept
    {
        return iterator{this, 0};
    }

    iterator end() const noexcept
    {
        return iterator{this, size()};
    }

private:
    Set<ObjKey> m_set;

    bool do_update_if_needed() const final
    {
        return m_set.update_if_needed();
    }

    bool do_init_from_parent() const final
    {
        return m_set.init_from_parent();
    }

    BPlusTree<ObjKey>& get_mutable_tree() const final
    {
        return *m_set.m_tree;
    }
};

template <>
void Set<ObjKey>::do_insert(size_t, ObjKey);
template <>
void Set<ObjKey>::do_erase(size_t);

template <>
void Set<ObjLink>::do_insert(size_t, ObjLink);
template <>
void Set<ObjLink>::do_erase(size_t);

template <>
void Set<Mixed>::do_insert(size_t, Mixed);
template <>
void Set<Mixed>::do_erase(size_t);

/// Compare set elements.
///
/// We cannot use `std::less<>` directly, because the ordering of set elements
/// impacts the file format. For primitive types this is trivial (and can indeed
/// be just `std::less<>`), but for example `Mixed` has specialized comparison
/// that defines equality of numeric types.
template <class T>
struct SetElementLessThan {
    bool operator()(const T& a, const T& b) const noexcept
    {
        // CAUTION: This routine is technically part of the file format, because
        // it determines the storage order of Set elements.
        return a < b;
    }
};

template <class T>
struct SetElementEquals {
    bool operator()(const T& a, const T& b) const noexcept
    {
        // CAUTION: This routine is technically part of the file format, because
        // it determines the storage order of Set elements.
        return a == b;
    }
};

template <>
struct SetElementLessThan<Mixed> {
    bool operator()(const Mixed& a, const Mixed& b) const noexcept
    {
        // CAUTION: This routine is technically part of the file format, because
        // it determines the storage order of Set elements.

        if (a.is_null() != b.is_null()) {
            // If a is NULL but not b, a < b.
            return a.is_null();
        }
        else if (a.is_null()) {
            // NULLs are equal.
            return false;
        }

        if (a.get_type() != b.get_type()) {
            return a.get_type() < b.get_type();
        }

        switch (a.get_type()) {
            case type_Int:
                return a.get<int64_t>() < b.get<int64_t>();
            case type_Bool:
                return a.get<bool>() < b.get<bool>();
            case type_String:
                return a.get<StringData>() < b.get<StringData>();
            case type_Binary:
                return a.get<BinaryData>() < b.get<BinaryData>();
            case type_Timestamp:
                return a.get<Timestamp>() < b.get<Timestamp>();
            case type_Float:
                return a.get<float>() < b.get<float>();
            case type_Double:
                return a.get<double>() < b.get<double>();
            case type_Decimal:
                return a.get<Decimal128>() < b.get<Decimal128>();
            case type_ObjectId:
                return a.get<ObjectId>() < b.get<ObjectId>();
            case type_UUID:
                return a.get<UUID>() < b.get<UUID>();
            case type_TypedLink:
                return a.get<ObjLink>() < b.get<ObjLink>();
            case type_Mixed:
                [[fallthrough]];
            case type_Link:
                [[fallthrough]];
            case type_LinkList:
                REALM_TERMINATE("Invalid Mixed payload in Set.");
        }
        return false;
    }
};

template <>
struct SetElementEquals<Mixed> {
    bool operator()(const Mixed& a, const Mixed& b) const noexcept
    {
        // CAUTION: This routine is technically part of the file format, because
        // it determines the storage order of Set elements.

        if (a.is_null() != b.is_null()) {
            return false;
        }
        else if (a.is_null()) {
            return true;
        }

        if (a.get_type() != b.get_type()) {
            return false;
        }

        switch (a.get_type()) {
            case type_Int:
                return a.get<int64_t>() == b.get<int64_t>();
            case type_Bool:
                return a.get<bool>() == b.get<bool>();
            case type_String:
                return a.get<StringData>() == b.get<StringData>();
            case type_Binary:
                return a.get<BinaryData>() == b.get<BinaryData>();
            case type_Timestamp:
                return a.get<Timestamp>() == b.get<Timestamp>();
            case type_Float:
                return a.get<float>() == b.get<float>();
            case type_Double:
                return a.get<double>() == b.get<double>();
            case type_Decimal:
                return a.get<Decimal128>() == b.get<Decimal128>();
            case type_ObjectId:
                return a.get<ObjectId>() == b.get<ObjectId>();
            case type_UUID:
                return a.get<UUID>() == b.get<UUID>();
            case type_TypedLink:
                return a.get<ObjLink>() == b.get<ObjLink>();
            case type_Mixed:
                [[fallthrough]];
            case type_Link:
                [[fallthrough]];
            case type_LinkList:
                REALM_TERMINATE("Invalid Mixed payload in Set.");
        }
        return false;
    }
};

template <class T>
inline Set<T>::Set(const Obj& obj, ColKey col_key)
    : Base(obj, col_key)
    , m_tree(new BPlusTree<value_type>(obj.get_alloc()))
{
    if (!col_key.is_set()) {
        throw LogicError(LogicError::collection_type_mismatch);
    }

    check_column_type<value_type>(m_col_key);

    m_tree->set_parent(this, 0); // ndx not used, implicit in m_owner
    if (m_obj) {
        // Fine because init_from_parent() is final.
        this->init_from_parent();
    }
}

template <class T>
inline Set<T>::Set(const Set& other)
    : Base(static_cast<const Base&>(other))
{
    // FIXME: If the other side needed an update, we could be using a stale ref
    // below.
    REALM_ASSERT(!other.update_if_needed());

    if (other.m_tree) {
        Allocator& alloc = other.m_tree->get_alloc();
        m_tree = std::make_unique<BPlusTree<T>>(alloc);
        m_tree->set_parent(this, 0);
        if (m_valid)
            m_tree->init_from_ref(other.m_tree->get_ref());
    }
}

template <class T>
inline Set<T>::Set(Set&& other) noexcept
    : Base(static_cast<Base&&>(other))
    , m_tree(std::exchange(other.m_tree, nullptr))
{
    if (m_tree) {
        m_tree->set_parent(this, 0);
    }
}

template <class T>
inline Set<T>& Set<T>::operator=(const Set& other)
{
    Base::operator=(static_cast<const Base&>(other));

    if (this != &other) {
        m_tree.reset();
        if (other.m_tree) {
            Allocator& alloc = other.m_tree->get_alloc();
            m_tree = std::make_unique<BPlusTree<T>>(alloc);
            m_tree->set_parent(this, 0);
            if (m_valid) {
                m_tree->init_from_ref(other.m_tree->get_ref());
            }
        }
    }

    return *this;
}

template <class T>
inline Set<T>& Set<T>::operator=(Set&& other) noexcept
{
    Base::operator=(static_cast<Base&&>(other));

    if (this != &other) {
        m_tree = std::exchange(other.m_tree, nullptr);
        if (m_tree) {
            m_tree->set_parent(this, 0);
        }
    }

    return *this;
}

template <typename U>
Set<U> Obj::get_set(ColKey col_key) const
{
    return Set<U>(*this, col_key);
}

inline LnkSet Obj::get_linkset(ColKey col_key) const
{
    return LnkSet{*this, col_key};
}

inline LnkSetPtr Obj::get_linkset_ptr(ColKey col_key) const
{
    return std::make_unique<LnkSet>(*this, col_key);
}

template <class T>
size_t Set<T>::find(T value) const
{
    auto it = find_impl(value);
    if (it != end() && SetElementEquals<T>{}(*it, value)) {
        return it.index();
    }
    return npos;
}

template <class T>
size_t Set<T>::find_any(Mixed value) const
{
    if constexpr (std::is_same_v<T, Mixed>) {
        return find(value);
    }
    else {
        if (value.is_null()) {
            if (!m_nullable) {
                return not_found;
            }
            return find(BPlusTree<T>::default_value(true));
        }
        else {
            return find(value.get<typename util::RemoveOptional<T>::type>());
        }
    }
}

template <class T>
REALM_NOINLINE auto Set<T>::find_impl(const T& value) const -> iterator
{
    auto b = this->begin();
    auto e = this->end();
    return std::lower_bound(b, e, value, SetElementLessThan<T>{});
}

template <class T>
std::pair<size_t, bool> Set<T>::insert(T value)
{
    update_if_needed();

    ensure_created();
    this->ensure_writeable();
    auto it = find_impl(value);

    if (it != this->end() && SetElementEquals<T>{}(*it, value)) {
        return {it.index(), false};
    }

    if (Replication* repl = m_obj.get_replication()) {
        // FIXME: We should emit an instruction regardless of element presence for the purposes of conflict
        // resolution in synchronized databases. The reason is that the new insertion may come at a later time
        // than an interleaving erase instruction, so emitting the instruction ensures that last "write" wins.
        this->insert_repl(repl, it.index(), value);
    }

    do_insert(it.index(), value);
    bump_content_version();
    return {it.index(), true};
}

template <class T>
std::pair<size_t, bool> Set<T>::insert_any(Mixed value)
{
    if constexpr (std::is_same_v<T, Mixed>) {
        return insert(value);
    }
    else {
        if (value.is_null()) {
            return insert_null();
        }
        else {
            return insert(value.get<typename util::RemoveOptional<T>::type>());
        }
    }
}

template <class T>
std::pair<size_t, bool> Set<T>::erase(T value)
{
    update_if_needed();
    this->ensure_writeable();

    auto it = find_impl(value);

    if (it == end() || !SetElementEquals<T>{}(*it, value)) {
        return {npos, false};
    }

    if (Replication* repl = m_obj.get_replication()) {
        this->erase_repl(repl, it.index(), value);
    }
    do_erase(it.index());
    bump_content_version();
    return {it.index(), true};
}

template <class T>
std::pair<size_t, bool> Set<T>::erase_any(Mixed value)
{
    if constexpr (std::is_same_v<T, Mixed>) {
        return erase(value);
    }
    else {
        if (value.is_null()) {
            return erase_null();
        }
        else {
            return erase(value.get<typename util::RemoveOptional<T>::type>());
        }
    }
}

template <class T>
inline std::pair<size_t, bool> Set<T>::insert_null()
{
    return insert(BPlusTree<T>::default_value(this->m_nullable));
}

template <class T>
std::pair<size_t, bool> Set<T>::erase_null()
{
    return erase(BPlusTree<T>::default_value(this->m_nullable));
}

template <class T>
REALM_NOINLINE size_t Set<T>::size() const
{
    if (!is_attached())
        return 0;
    update_if_needed();
    if (!m_valid) {
        return 0;
    }
    return m_tree->size();
}

template <class T>
inline bool Set<T>::is_null(size_t ndx) const
{
    return m_nullable && value_is_null(get(ndx));
}

template <class T>
inline void Set<T>::clear()
{
    ensure_created();
    update_if_needed();
    this->ensure_writeable();
    if (size() > 0) {
        if (Replication* repl = this->m_obj.get_replication()) {
            this->clear_repl(repl);
        }
        m_tree->clear();
        bump_content_version();

        // For Set<ObjKey>, we are sure that there are no longer any unresolved
        // links.
        m_tree->set_context_flag(false);
    }
}

template <class T>
inline Mixed Set<T>::min(size_t* return_ndx) const
{
    update_if_needed();
    return MinHelper<T>::eval(*m_tree, return_ndx);
}

template <class T>
inline Mixed Set<T>::max(size_t* return_ndx) const
{
    update_if_needed();
    return MaxHelper<T>::eval(*m_tree, return_ndx);
}

template <class T>
inline Mixed Set<T>::sum(size_t* return_cnt) const
{
    update_if_needed();
    return SumHelper<T>::eval(*m_tree, return_cnt);
}

template <class T>
inline Mixed Set<T>::avg(size_t* return_cnt) const
{
    update_if_needed();
    return AverageHelper<T>::eval(*m_tree, return_cnt);
}

void set_sorted_indices(size_t sz, std::vector<size_t>& indices, bool ascending);

template <class T>
inline void Set<T>::sort(std::vector<size_t>& indices, bool ascending) const
{
    auto sz = size();
    set_sorted_indices(sz, indices, ascending);
}

template <class T>
inline void Set<T>::distinct(std::vector<size_t>& indices, util::Optional<bool> sort_order) const
{
    auto ascending = !sort_order || *sort_order;
    sort(indices, ascending);
}

template <class T>
void Set<T>::do_insert(size_t ndx, T value)
{
    m_tree->insert(ndx, value);
}

template <class T>
void Set<T>::do_erase(size_t ndx)
{
    m_tree->erase(ndx);
}

template <class T>
template <class Rhs>
bool Set<T>::is_subset_of(const Rhs& rhs) const
{
    return is_subset_of(std::begin(rhs), std::end(rhs));
}

template <class T>
template <class It1, class It2>
bool Set<T>::is_subset_of(It1 first, It2 last) const
{
    return std::includes(first, last, begin(), end(), SetElementLessThan<T>{});
}

template <class T>
template <class Rhs>
bool Set<T>::is_strict_subset_of(const Rhs& rhs) const
{
    if constexpr (std::is_same_v<Rhs, Set<T>>) {
        return size() != rhs.size() && is_subset_of(rhs);
    }
    else {
        return is_strict_subset_of(rhs.begin(), rhs.end());
    }
}

template <class T>
template <class It1, class It2>
bool Set<T>::is_strict_subset_of(It1 begin, It2 end) const
{
    if (size_t(std::distance(begin, end)) == size())
        return false;
    return is_subset_of(begin, end);
}

template <class T>
template <class Rhs>
bool Set<T>::is_superset_of(const Rhs& rhs) const
{
    return is_superset_of(std::begin(rhs), std::end(rhs));
}

template <class T>
template <class It1, class It2>
bool Set<T>::is_superset_of(It1 first, It2 last) const
{
    return std::includes(begin(), end(), first, last, SetElementLessThan<T>{});
}

template <class T>
template <class Rhs>
bool Set<T>::is_strict_superset_of(const Rhs& rhs) const
{
    if constexpr (std::is_same_v<Rhs, Set<T>>) {
        return size() != rhs.size() && is_superset_of(rhs);
    }
    else {
        return is_strict_superset_of(rhs.begin(), rhs.end());
    }
}

template <class T>
template <class It1, class It2>
bool Set<T>::is_strict_superset_of(It1 begin, It2 end) const
{
    if (size_t(std::distance(begin, end)) == size())
        return false;
    return is_superset_of(begin, end);
}

template <class T>
template <class Rhs>
bool Set<T>::intersects(const Rhs& rhs) const
{
    return intersects(std::begin(rhs), std::end(rhs));
}

template <class T>
template <class It1, class It2>
bool Set<T>::intersects(It1 first, It2 last) const
{
    SetElementLessThan<T> less;
    auto it = begin();
    while (it != end() && first != last) {
        if (less(*it, *first)) {
            ++it;
        }
        else if (less(*first, *it)) {
            ++first;
        }
        else {
            return true;
        }
    }
    return false;
}

template <class T>
template <class Rhs>
bool Set<T>::set_equals(const Rhs& rhs) const
{
    if (size() != rhs.size())
        return false;
    return set_equals(rhs.begin(), rhs.end());
}

template <class T>
template <class It1, class It2>
bool Set<T>::set_equals(It1 begin2, It2 end2) const
{
    auto end1 = end();

    auto it1 = begin();
    auto it2 = begin2;

    auto cmp = SetElementEquals<T>{};

    for (; it1 != end1 && it2 != end2; ++it1, ++it2) {
        if (!cmp(*it1, *it2)) {
            return false;
        }
    }
    return it1 == end1 && it2 == end2;
}

template <class T>
template <class Rhs>
inline void Set<T>::assign_union(const Rhs& rhs)
{
    assign_union(std::begin(rhs), std::end(rhs));
}

template <class T>
template <class It1, class It2>
void Set<T>::assign_union(It1 first, It2 last)
{
    std::vector<T> the_diff;
    std::set_difference(first, last, begin(), end(), std::back_inserter(the_diff), SetElementLessThan<T>{});
    // 'the_diff' now contains all the elements that are in foreign set, but not in 'this'
    // Now insert those elements
    for (auto value : the_diff) {
        insert(value);
    }
}

template <class T>
template <class Rhs>
inline void Set<T>::assign_intersection(const Rhs& rhs)
{
    assign_intersection(std::begin(rhs), std::end(rhs));
}

template <class T>
template <class It1, class It2>
void Set<T>::assign_intersection(It1 first, It2 last)
{
    std::vector<T> intersection;
    std::set_intersection(first, last, begin(), end(), std::back_inserter(intersection), SetElementLessThan<T>{});
    clear();
    // Elements in intersection comes from foreign set, so ok to use here
    for (auto value : intersection) {
        insert(value);
    }
}

template <class T>
template <class Rhs>
inline void Set<T>::assign_difference(const Rhs& rhs)
{
    assign_difference(std::begin(rhs), std::end(rhs));
}

template <class T>
template <class It1, class It2>
void Set<T>::assign_difference(It1 first, It2 last)
{
    std::vector<T> intersection;
    std::set_intersection(first, last, begin(), end(), std::back_inserter(intersection), SetElementLessThan<T>{});
    // 'intersection' now contains all the elements that are in both foreign set and 'this'.
    // Remove those elements. The elements comes from the foreign set, so ok to refer to.
    for (auto value : intersection) {
        erase(value);
    }
}

template <class T>
template <class Rhs>
inline void Set<T>::assign_symmetric_difference(const Rhs& rhs)
{
    assign_symmetric_difference(std::begin(rhs), std::end(rhs));
}

template <class T>
template <class It1, class It2>
void Set<T>::assign_symmetric_difference(It1 first, It2 last)
{
    std::vector<T> difference;
    std::set_difference(first, last, begin(), end(), std::back_inserter(difference), SetElementLessThan<T>{});
    std::vector<T> intersection;
    std::set_intersection(first, last, begin(), end(), std::back_inserter(intersection), SetElementLessThan<T>{});
    // Now remove the common elements and add the differences
    for (auto value : intersection) {
        erase(value);
    }
    for (auto value : difference) {
        insert(value);
    }
}

inline bool LnkSet::operator==(const LnkSet& other) const
{
    return m_set == other.m_set;
}

inline bool LnkSet::operator!=(const LnkSet& other) const
{
    return m_set != other.m_set;
}

inline ObjKey LnkSet::get(size_t ndx) const
{
    update_if_needed();
    return m_set.get(virtual2real(ndx));
}

inline size_t LnkSet::find(ObjKey value) const
{
    update_if_needed();

    if (value.is_unresolved()) {
        return not_found;
    }

    size_t ndx = m_set.find(value);
    if (ndx == not_found) {
        return not_found;
    }
    return real2virtual(ndx);
}

inline size_t LnkSet::find_first(ObjKey value) const
{
    return find(value);
}

inline size_t LnkSet::size() const
{
    update_if_needed();
    return m_set.size() - num_unresolved();
}

inline std::pair<size_t, bool> LnkSet::insert(ObjKey value)
{
    REALM_ASSERT(!value.is_unresolved());
    update_if_needed();

    auto [ndx, inserted] = m_set.insert(value);
    return {real2virtual(ndx), inserted};
}

inline std::pair<size_t, bool> LnkSet::erase(ObjKey value)
{
    REALM_ASSERT(!value.is_unresolved());
    update_if_needed();

    auto [ndx, removed] = m_set.erase(value);
    if (removed) {
        ndx = real2virtual(ndx);
    }
    return {ndx, removed};
}

inline bool LnkSet::is_null(size_t ndx) const
{
    update_if_needed();
    return m_set.is_null(virtual2real(ndx));
}

inline Mixed LnkSet::get_any(size_t ndx) const
{
    update_if_needed();
    return m_set.get_any(virtual2real(ndx));
}

inline std::pair<size_t, bool> LnkSet::insert_null()
{
    update_if_needed();
    auto [ndx, inserted] = m_set.insert_null();
    return {real2virtual(ndx), inserted};
}

inline std::pair<size_t, bool> LnkSet::erase_null()
{
    update_if_needed();
    auto [ndx, erased] = m_set.erase_null();
    if (erased) {
        ndx = real2virtual(ndx);
    }
    return {ndx, erased};
}

inline std::pair<size_t, bool> LnkSet::insert_any(Mixed value)
{
    update_if_needed();
    auto [ndx, inserted] = m_set.insert_any(value);
    return {real2virtual(ndx), inserted};
}

inline std::pair<size_t, bool> LnkSet::erase_any(Mixed value)
{
    auto [ndx, erased] = m_set.erase_any(value);
    if (erased) {
        ndx = real2virtual(ndx);
    }
    return {ndx, erased};
}

inline void LnkSet::clear()
{
    m_set.clear();
    clear_unresolved();
}

inline Mixed LnkSet::min(size_t* return_ndx) const
{
    size_t found = not_found;
    auto value = m_set.min(&found);
    if (found != not_found && return_ndx) {
        *return_ndx = real2virtual(found);
    }
    return value;
}

inline Mixed LnkSet::max(size_t* return_ndx) const
{
    size_t found = not_found;
    auto value = m_set.max(&found);
    if (found != not_found && return_ndx) {
        *return_ndx = real2virtual(found);
    }
    return value;
}

inline Mixed LnkSet::sum(size_t* return_cnt) const
{
    static_cast<void>(return_cnt);
    REALM_TERMINATE("Not implemented");
}

inline Mixed LnkSet::avg(size_t* return_cnt) const
{
    static_cast<void>(return_cnt);
    REALM_TERMINATE("Not implemented");
}

inline void LnkSet::sort(std::vector<size_t>& indices, bool ascending) const
{
    update_if_needed();

    // Map the input indices to real indices.
    std::transform(indices.begin(), indices.end(), indices.begin(), [this](size_t ndx) {
        return virtual2real(ndx);
    });

    m_set.sort(indices, ascending);

    // Map the output indices to virtual indices.
    std::transform(indices.begin(), indices.end(), indices.begin(), [this](size_t ndx) {
        return real2virtual(ndx);
    });
}

inline void LnkSet::distinct(std::vector<size_t>& indices, util::Optional<bool> sort_order) const
{
    update_if_needed();

    // Map the input indices to real indices.
    std::transform(indices.begin(), indices.end(), indices.begin(), [this](size_t ndx) {
        return virtual2real(ndx);
    });

    m_set.distinct(indices, sort_order);

    // Map the output indices to virtual indices.
    std::transform(indices.begin(), indices.end(), indices.begin(), [this](size_t ndx) {
        return real2virtual(ndx);
    });
}

inline const Obj& LnkSet::get_obj() const noexcept
{
    return m_set.get_obj();
}

inline bool LnkSet::is_attached() const
{
    return m_set.is_attached();
}

inline bool LnkSet::has_changed() const
{
    return m_set.has_changed();
}

inline ColKey LnkSet::get_col_key() const noexcept
{
    return m_set.get_col_key();
}

inline size_t LnkSet::find_any(Mixed value) const
{
    if (value.is_null())
        return not_found;
    if (value.get_type() != type_Link)
        return not_found;
    size_t found = find(value.get<ObjKey>());
    if (found != not_found) {
        found = real2virtual(found);
    }
    return found;
}

inline bool LnkSet::is_obj_valid(size_t) const noexcept
{
    // LnkSet cannot contain NULL links.
    return true;
}

inline Obj LnkSet::get_object(size_t ndx) const
{
    ObjKey key = get(ndx);
    return get_target_table()->get_object(key);
}

inline ObjKey LnkSet::get_key(size_t ndx) const
{
    return get(ndx);
}

template <class Rhs>
inline void LnkSet::assign_union(const Rhs& rhs)
{
    assign_union(std::begin(rhs), std::end(rhs));
}

template <class It1, class It2>
inline void LnkSet::assign_union(It1 first, It2 last)
{
    m_set.assign_union(first, last);
    update_unresolved();
}

template <class Rhs>
inline void LnkSet::assign_intersection(const Rhs& rhs)
{
    assign_intersection(std::begin(rhs), std::end(rhs));
}

template <class It1, class It2>
inline void LnkSet::assign_intersection(It1 first, It2 last)
{
    m_set.assign_intersection(first, last);
    update_unresolved();
}

template <class Rhs>
inline void LnkSet::assign_difference(const Rhs& rhs)
{
    assign_difference(std::begin(rhs), std::end(rhs));
}

template <class It1, class It2>
inline void LnkSet::assign_difference(It1 first, It2 last)
{
    m_set.assign_difference(first, last);
    update_unresolved();
}

template <class Rhs>
inline void LnkSet::assign_symmetric_difference(const Rhs& rhs)
{
    assign_symmetric_difference(std::begin(rhs), std::end(rhs));
}

template <class It1, class It2>
inline void LnkSet::assign_symmetric_difference(It1 first, It2 last)
{
    m_set.assign_symmetric_difference(first, last);
    update_unresolved();
}

} // namespace realm

#endif // REALM_SET_HPP
