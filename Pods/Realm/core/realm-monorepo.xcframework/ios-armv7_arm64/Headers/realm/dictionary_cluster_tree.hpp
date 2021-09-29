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

#ifndef REALM_DICTIONARY_CLUSTER_TREE_HPP
#define REALM_DICTIONARY_CLUSTER_TREE_HPP

#include <realm/cluster_tree.hpp>

namespace realm {

class DictionaryClusterTree : public ClusterTree {
public:
    static constexpr ColKey s_values_col = ColKey(ColKey::Idx{1}, col_type_Mixed, ColumnAttrMask(), 0);
    static constexpr ColKey s_collision_col = ColKey(
        ColKey::Idx{2}, col_type_Int,
        []() {
            ColumnAttrMask m;
            m.set(ColumnAttr::col_attr_List);
            return m;
        }(),
        0);

    DictionaryClusterTree(ArrayParent* owner, DataType, Allocator& alloc, size_t ndx);
    ~DictionaryClusterTree() override;

    void init_from_parent();

    void destroy()
    {
        m_root->destroy_deep();

        bump_content_version();
        bump_storage_version();

        m_size = 0;
    }

    Mixed get_key(const ClusterNode::State& s) const;
    ObjKey find_sibling(ClusterNode::State&, Mixed key) const noexcept;
    ClusterNode::State try_get_with_key(ObjKey k, Mixed) const noexcept;
    size_t get_ndx_with_key(ObjKey k, Mixed) const noexcept;

    ColKey get_keys_column_key() const
    {
        return m_keys_col;
    }

    bool has_collisions() const
    {
        return m_has_collision_column;
    }

    void add_columns()
    {
        insert_column(m_keys_col);
        insert_column(s_values_col);
    }

    void create_collision_column()
    {
        insert_column(s_collision_col);
        m_has_collision_column = true;
    }

    ClusterNode::State insert(ObjKey k, Mixed key, Mixed value)
    {
        FieldValues values;
        values.emplace_back(m_keys_col, key);
        values.emplace_back(s_values_col, value);
        return ClusterTree::insert(k, values);
    }

    // Overriding members of ClusterTree:
    void for_each_and_every_column(ColIterateFunction func) const final
    {
        func(m_keys_col);
        func(s_values_col);
        if (m_has_collision_column) {
            func(s_collision_col);
        }
    }
    void update_indexes(ObjKey, const FieldValues&) final {}
    void cleanup_key(ObjKey) final {}
    void set_spec(ArrayPayload&, ColKey::Idx) const final {}
    bool is_string_enum_type(ColKey::Idx) const final
    {
        return false;
    }
    const Table* get_owning_table() const noexcept final
    {
        // A dictionary is not owned by a table, but by an object
        // The generic cluster implementation relies on the fact that
        // dictionary clusters does not have an owning table.
        return nullptr;
    }
    std::unique_ptr<ClusterNode> get_root_from_parent() final
    {
        return create_root_from_parent(m_owner, m_ndx_in_cluster);
    }
    Mixed min(size_t* return_ndx = nullptr) const;
    Mixed max(size_t* return_ndx = nullptr) const;
    Mixed sum(size_t* return_cnt = nullptr, DataType type = type_Mixed) const;
    Mixed avg(size_t* return_cnt = nullptr, DataType type = type_Mixed) const;

private:
    template <typename AggregateType>
    void do_accumulate(size_t* return_ndx, AggregateType& agg) const;

    ArrayParent* m_owner;
    size_t m_ndx_in_cluster;
    ColKey m_keys_col;
    bool m_has_collision_column = false;
};

} // namespace realm

#endif /* REALM_DICTIONARY_CLUSTER_TREE_HPP */
