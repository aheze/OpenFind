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

    // Overriding members of CollectionBase:
    std::unique_ptr<CollectionBase> clone_collection() const;
    size_t size() const final;
    bool is_null(size_t ndx) const final;
    Mixed get_any(size_t ndx) const final;
    std::pair<Mixed, Mixed> get_pair(size_t ndx) const;
    size_t find_any(Mixed value) const final;

    Mixed min(size_t* return_ndx = nullptr) const final;
    Mixed max(size_t* return_ndx = nullptr) const final;
    Mixed sum(size_t* return_cnt = nullptr) const final;
    Mixed avg(size_t* return_cnt = nullptr) const final;

    void sort(std::vector<size_t>& indices, bool ascending = true) const final;
    void distinct(std::vector<size_t>& indices, util::Optional<bool> sort_order = util::none) const final;

    void create();

    // first points to inserted/updated element.
    // second is true if the element was inserted
    std::pair<Iterator, bool> insert(Mixed key, Mixed value);
    std::pair<Iterator, bool> insert(Mixed key, const Obj& obj);

    // throws std::out_of_range if key is not found
    Mixed get(Mixed key) const;
    // Noexcept version
    util::Optional<Mixed> try_get(Mixed key) const noexcept;
    // adds entry if key is not found
    const Mixed operator[](Mixed key);

    bool contains(Mixed key);
    Iterator find(Mixed key);

    void erase(Mixed key);
    void erase(Iterator it);

    void nullify(Mixed);

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

private:
    friend class DictionaryAggregate;
    mutable DictionaryClusterTree* m_clusters = nullptr;
    DataType m_key_type = type_String;

    bool init_from_parent() const final;
    Mixed do_get(const ClusterNode::State&) const;
    std::pair<Mixed, Mixed> do_get_pair(const ClusterNode::State&) const;

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
