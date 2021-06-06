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

    DictionaryClusterTree(ArrayParent* owner, DataType, Allocator& alloc, size_t ndx);
    ~DictionaryClusterTree() override;

    void destroy()
    {
        m_root->destroy_deep();

        bump_content_version();
        bump_storage_version();

        m_size = 0;
    }

    ColKey get_keys_column_key() const
    {
        return m_keys_col;
    }

    void add_columns()
    {
        insert_column(m_keys_col);
        insert_column(s_values_col);
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
    }
    void update_indexes(ObjKey, const FieldValues&) final {}
    void cleanup_key(ObjKey) final {}
    void set_spec(ArrayPayload&, ColKey::Idx) const final {}
    bool is_string_enum_type(ColKey::Idx) const final
    {
        return false;
    }
    const Table* get_owning_table() const final
    {
        return nullptr; // FIXME: Should return the owning table
    }
    std::unique_ptr<ClusterNode> get_root_from_parent() final
    {
        return create_root_from_parent(m_owner, m_ndx_in_cluster);
    }
    Mixed min(size_t* return_ndx = nullptr) const;
    Mixed max(size_t* return_ndx = nullptr) const;
    Mixed sum(size_t* return_cnt = nullptr) const;
    Mixed avg(size_t* return_cnt = nullptr) const;

private:
    ArrayParent* m_owner;
    size_t m_ndx_in_cluster;
    ColKey m_keys_col;
};

} // namespace realm

#endif /* REALM_DICTIONARY_CLUSTER_TREE_HPP */
