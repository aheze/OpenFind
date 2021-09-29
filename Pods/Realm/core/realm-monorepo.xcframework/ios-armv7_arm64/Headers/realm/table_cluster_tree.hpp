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

#ifndef REALM_TABLE_CLUSTER_TREE_HPP
#define REALM_TABLE_CLUSTER_TREE_HPP

#include "realm/cluster_tree.hpp"
#include "realm/obj.hpp"

namespace realm {

class TableClusterTree : public ClusterTree {
public:
    class Iterator;

    TableClusterTree(Table* owner, Allocator& alloc, size_t top_position_for_cluster_tree);
    ~TableClusterTree() override;

    Obj insert(ObjKey k, const FieldValues& values);

    Obj get(ObjKey k) const
    {
        auto state = ClusterTree::get(k);
        return Obj(get_table_ref(), state.mem, k, state.index);
    }
    Obj get(size_t ndx) const
    {
        ObjKey k;
        auto state = ClusterTree::get(ndx, k);
        return Obj(get_table_ref(), state.mem, k, state.index);
    }

    void clear(CascadeState&);
    void enumerate_string_column(ColKey col_key);

    // Specialization of ClusterTree interface
    const Table* get_owning_table() const noexcept override
    {
        return m_owner;
    }

    void cleanup_key(ObjKey k) override;
    void update_indexes(ObjKey k, const FieldValues& init_values) override;
    void for_each_and_every_column(ColIterateFunction func) const override;
    void set_spec(ArrayPayload& arr, ColKey::Idx col_ndx) const override;
    bool is_string_enum_type(ColKey::Idx col_ndx) const override;
    std::unique_ptr<ClusterNode> get_root_from_parent() override;

private:
    Table* m_owner;
    size_t m_top_position_for_cluster_tree;

    TableRef get_table_ref() const;
    void remove_all_links(CascadeState&);
};

class TableClusterTree::Iterator : public ClusterTree::Iterator {
public:
    typedef std::forward_iterator_tag iterator_category;
    typedef Obj value_type;
    typedef Obj* pointer;
    typedef Obj& reference;

    Iterator(const TableClusterTree& t, size_t ndx)
        : ClusterTree::Iterator(t, ndx)
    {
        m_table = t.get_table_ref();
    }
    Iterator(TableRef table, const ClusterTree& t, size_t ndx)
        : ClusterTree::Iterator(t, ndx)
    {
        m_table = table;
    }

    // If the object pointed to by the iterator is deleted, you will get an exception if
    // you try to dereference the iterator before advancing it.

    reference operator*() const
    {
        return *operator->();
    }
    pointer operator->() const;
    Iterator& operator++()
    {
        return static_cast<Iterator&>(ClusterTree::Iterator::operator++());
    }
    Iterator& operator+=(ptrdiff_t adj)
    {
        return static_cast<Iterator&>(ClusterTree::Iterator::operator+=(adj));
    }
    Iterator operator+(ptrdiff_t adj)
    {
        return Iterator(m_table, m_tree, get_position() + adj);
    }

protected:
    mutable Obj m_obj;
    TableRef m_table;
};

} // namespace realm

#endif /* REALM_TABLE_CLUSTER_TREE_HPP */
