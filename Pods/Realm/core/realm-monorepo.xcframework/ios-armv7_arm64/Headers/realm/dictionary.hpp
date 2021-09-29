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

#ifndef REALM_DICTIONARY_HPP
#define REALM_DICTIONARY_HPP

#include <realm/collection.hpp>
#include <realm/obj.hpp>
#include <realm/mixed.hpp>
#include <realm/array_mixed.hpp>
#include <realm/dictionary_cluster_tree.hpp>

namespace realm {

class DictionaryClusterTree;

class Dictionary final : public CollectionBaseImpl<CollectionBase> {
public:
    using Base = CollectionBaseImpl<CollectionBase>;
    class Iterator;

    Dictionary() {}
    ~Dictionary();

    Dictionary(const Obj& obj, ColKey col_key);
    Dictionary(const Dictionary& other)
        : Base(static_cast<const Base&>(other))
        , m_key_type(other.m_key_type)
    {
        *this = other;
    }
    Dictionary& operator=(const Dictionary& other);

    bool operator==(const Dictionary& other) const noexcept
    {
        return CollectionBaseImpl<CollectionBase>::operator==(other);
    }

    DataType get_key_data_type() const;
    DataType get_value_data_type() const;

    std::pair<Mixed, Mixed> get_pair(size_t ndx) const;
    Mixed get_key(size_t ndx) const;

    // Overriding members of CollectionBase:
    std::unique_ptr<CollectionBase> clone_collection() const final;
    size_t size() const final;
    bool is_null(size_t ndx) const final;
    Mixed get_any(size_t ndx) const final;
    size_t find_any(Mixed value) const final;
    size_t find_any_key(Mixed value) const noexcept;

    util::Optional<Mixed> min(size_t* return_ndx = nullptr) const final;
    util::Optional<Mixed> max(size_t* return_ndx = nullptr) const final;
    util::Optional<Mixed> sum(size_t* return_cnt = nullptr) const final;
    util::Optional<Mixed> avg(size_t* return_cnt = nullptr) const final;

    void sort(std::vector<size_t>& indices, bool ascending = true) const final;
    void distinct(std::vector<size_t>& indices, util::Optional<bool> sort_order = util::none) const final;
    void sort_keys(std::vector<size_t>& indices, bool ascending = true) const;
    void distinct_keys(std::vector<size_t>& indices, util::Optional<bool> sort_order = util::none) const;

    void create();

    // first points to inserted/updated element.
    // second is true if the element was inserted
    std::pair<Iterator, bool> insert(Mixed key, Mixed value);
    std::pair<Iterator, bool> insert(Mixed key, const Obj& obj);

    Obj create_and_insert_linked_object(Mixed key);

    // throws std::out_of_range if key is not found
    Mixed get(Mixed key) const;
    // Noexcept version
    util::Optional<Mixed> try_get(Mixed key) const noexcept;
    // adds entry if key is not found
    const Mixed operator[](Mixed key);

    Obj get_object(StringData key)
    {
        auto val = try_get(key);
        Obj obj;
        if (val && (*val).is_type(type_Link)) {
            return get_target_table()->get_object((*val).get<ObjKey>());
        }
        return obj;
    }

    bool contains(Mixed key) const noexcept;
    Iterator find(Mixed key) const noexcept;

    void erase(Mixed key);
    void erase(Iterator it);
    bool try_erase(Mixed key);

    void nullify(Mixed);
    void remove_backlinks(CascadeState& state) const;

    void clear() final;

    template <class T>
    void for_all_values(T&& f)
    {
        if (m_clusters) {
            ArrayMixed leaf(m_obj.get_alloc());
            // Iterate through cluster and call f on each value
            auto trv_func = [&leaf, &f](const Cluster* cluster) {
                size_t e = cluster->node_size();
                cluster->init_leaf(DictionaryClusterTree::s_values_col, &leaf);
                for (size_t i = 0; i < e; i++) {
                    f(leaf.get(i));
                }
                // Continue
                return false;
            };
            m_clusters->traverse(trv_func);
        }
    }

    template <class T, class Func>
    void for_all_keys(Func&& f)
    {
        if (m_clusters) {
            typename ColumnTypeTraits<T>::cluster_leaf_type leaf(m_obj.get_alloc());
            ColKey col = m_clusters->get_keys_column_key();
            // Iterate through cluster and call f on each value
            auto trv_func = [&leaf, &f, col](const Cluster* cluster) {
                size_t e = cluster->node_size();
                cluster->init_leaf(col, &leaf);
                for (size_t i = 0; i < e; i++) {
                    f(leaf.get(i));
                }
                // Continue
                return false;
            };
            m_clusters->traverse(trv_func);
        }
    }


    Iterator begin() const;
    Iterator end() const;

    static ObjKey get_internal_obj_key(Mixed key)
    {
        return ObjKey{int64_t(key.hash() & s_hash_mask)};
    }

#ifdef REALM_DEBUG
    static uint64_t set_hash_mask(uint64_t mask)
    {
        auto tmp = s_hash_mask;
        s_hash_mask = mask;
        return tmp;
    }
#else
    static uint64_t set_hash_mask(uint64_t)
    {
        return 0;
    }
#endif

private:
    template <typename T, typename Op>
    friend class CollectionColumnAggregate;
    friend class DictionaryLinkValues;
    mutable std::unique_ptr<DictionaryClusterTree> m_clusters;
    DataType m_key_type = type_String;

#ifdef REALM_DEBUG
    static uint64_t s_hash_mask;
#else
    static constexpr uint64_t s_hash_mask = 0x7FFFFFFFFFFFFFFFULL;
#endif

    bool init_from_parent() const final;
    Mixed do_get(const ClusterNode::State&) const;
    Mixed do_get_key(const ClusterNode::State&) const;
    std::pair<Mixed, Mixed> do_get_pair(const ClusterNode::State&) const;
    bool clear_backlink(Mixed value, CascadeState& state) const;
    void align_indices(std::vector<size_t>& indices) const;
    void swap_content(Array& fields1, Array& fields2, size_t index1, size_t index2);
    ObjKey handle_collision_in_erase(const Mixed& key, ObjKey k, ClusterNode::State& state);

    friend struct CollectionIterator<Dictionary>;
};

class Dictionary::Iterator : public ClusterTree::Iterator {
public:
    typedef std::forward_iterator_tag iterator_category;
    typedef std::pair<const Mixed, Mixed> value_type;
    typedef ptrdiff_t difference_type;
    typedef const value_type* pointer;
    typedef const value_type& reference;

    value_type operator*() const;

    Iterator& operator++()
    {
        return static_cast<Iterator&>(ClusterTree::Iterator::operator++());
    }
    Iterator& operator+=(ptrdiff_t adj)
    {
        return static_cast<Iterator&>(ClusterTree::Iterator::operator+=(adj));
    }
    Iterator operator+(ptrdiff_t n) const
    {
        Iterator ret(*this);
        ret += n;
        return ret;
    }

private:
    friend class Dictionary;
    using ClusterTree::Iterator::get_position;

    DataType m_key_type;

    Iterator(const Dictionary* dict, size_t pos);
};

// An interface used when the value type of the dictionary consists of
// links to a single table. Implementation of the ObjList interface on
// top of a Dictionary of objects. This is the dictionary equivilent of
// LnkLst and LnkSet.
class DictionaryLinkValues final : public ObjCollectionBase<CollectionBase> {
public:
    DictionaryLinkValues() = default;
    DictionaryLinkValues(const Obj& obj, ColKey col_key);
    DictionaryLinkValues(const Dictionary& source);

    // Overrides of ObjList:
    ObjKey get_key(size_t ndx) const final;
    bool is_obj_valid(size_t ndx) const noexcept final;
    Obj get_object(size_t row_ndx) const final;

    // Overrides of CollectionBase, these simply forward to the underlying dictionary.
    size_t size() const final
    {
        return m_source.size();
    }
    bool is_null(size_t ndx) const final
    {
        return m_source.is_null(ndx);
    }
    Mixed get_any(size_t ndx) const final
    {
        return m_source.get_any(ndx);
    }
    void clear() final
    {
        m_source.clear();
    }
    util::Optional<Mixed> min(size_t* return_ndx = nullptr) const final
    {
        return m_source.min(return_ndx);
    }
    util::Optional<Mixed> max(size_t* return_ndx = nullptr) const final
    {
        return m_source.max(return_ndx);
    }
    util::Optional<Mixed> sum(size_t* return_cnt = nullptr) const final
    {
        return m_source.sum(return_cnt);
    }
    util::Optional<Mixed> avg(size_t* return_cnt = nullptr) const final
    {
        return m_source.avg(return_cnt);
    }
    std::unique_ptr<CollectionBase> clone_collection() const final
    {
        return std::make_unique<DictionaryLinkValues>(m_source);
    }
    LinkCollectionPtr clone_obj_list() const final
    {
        return std::make_unique<DictionaryLinkValues>(m_source);
    }
    void sort(std::vector<size_t>& indices, bool ascending = true) const final
    {
        m_source.sort(indices, ascending);
    }
    void distinct(std::vector<size_t>& indices, util::Optional<bool> sort_order = util::none) const final
    {
        m_source.distinct(indices, sort_order);
    }
    size_t find_any(Mixed value) const final
    {
        return m_source.find_any(value);
    }
    const Obj& get_obj() const noexcept final
    {
        return m_source.get_obj();
    }
    ColKey get_col_key() const noexcept final
    {
        return m_source.get_col_key();
    }
    bool has_changed() const final
    {
        return m_source.has_changed();
    }

    // Overrides of ObjCollectionBase:
    bool do_update_if_needed() const final
    {
        return m_source.update_if_needed();
    }
    bool do_init_from_parent() const final
    {
        return m_source.init_from_parent();
    }
    BPlusTree<ObjKey>* get_mutable_tree() const
    {
        // We are faking being an ObjList because the underlying storage is not
        // actually a BPlusTree<ObjKey> for dictionaries it is all mixed values.
        // But this is ok, because we don't need to deal with unresolved link
        // maintenance because they are not hidden from view in dictionaries in
        // the same way as for LnkSet and LnkLst. This means that the functions
        // that call get_mutable_tree do not need to do anything for dictionaries.
        return nullptr;
    }

private:
    Dictionary m_source;
};


inline std::pair<Dictionary::Iterator, bool> Dictionary::insert(Mixed key, const Obj& obj)
{
    return insert(key, Mixed(obj.get_link()));
}

inline std::unique_ptr<CollectionBase> Dictionary::clone_collection() const
{
    return m_obj.get_dictionary_ptr(m_col_key);
}


} // namespace realm

#endif /* SRC_REALM_DICTIONARY_HPP_ */
