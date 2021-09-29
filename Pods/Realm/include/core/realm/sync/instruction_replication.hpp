/*************************************************************************
 *
 * Copyright 2017 Realm Inc.
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

#ifndef REALM_SYNC_IMPL_INSTRUCTION_REPLICATION_HPP
#define REALM_SYNC_IMPL_INSTRUCTION_REPLICATION_HPP

#include <realm/replication.hpp>
#include <realm/sync/instructions.hpp>
#include <realm/sync/object.hpp>
#include <realm/sync/changeset_encoder.hpp>

namespace realm {
namespace sync {


class SyncReplication : public TrivialReplication {
public:
    explicit SyncReplication(const std::string& realm_path);
    void set_short_circuit(bool) noexcept;
    bool is_short_circuited() const noexcept;

    // reset() resets the encoder, the selected tables and the cache. It is
    // called by do_initiate_transact(), but can be called at the other times
    // as well.
    virtual void reset();

    ChangesetEncoder& get_instruction_encoder() noexcept;
    const ChangesetEncoder& get_instruction_encoder() const noexcept;

    //@{
    /// Generate instructions for Object Store tables. These must be called
    /// prior to calling the equivalent functions in Core's API. When creating a
    /// class-like table, `add_class()` must be called prior to
    /// `Group::insert_group_level_table()`. Similarly, `create_object()` or
    /// `create_object_with_primary_key()` must be called prior to
    /// `Table::insert_empty_row()` and/or `Table::set_int_unique()` or
    /// `Table::set_string_unique()` or `Table::set_null_unique()`.
    ///
    /// If a class-like table is added, or an object-like row is inserted,
    /// without calling these methods first, an exception will be thrown.
    ///
    /// A "class-like table" is defined as a table whose name begins with
    /// "class_" (this is the convention used by Object Store). Non-class-like
    /// tables can be created and modified using Core's API without calling
    /// these functions, because they do not result in instructions being
    /// emitted.
    void prepare_erase_table(StringData table_name);
    //@}

    // TrivialReplication interface:
    void initialize(DB&) override;

    // TransactLogConvenientEncoder interface:
    void add_class(TableKey tk, StringData table_name, bool is_embedded) override;
    void add_class_with_primary_key(TableKey tk, StringData table_name, DataType pk_type, StringData pk_field,
                                    bool nullable) override;
    void create_object(const Table*, GlobalKey) override;
    void create_object_with_primary_key(const Table*, ObjKey, Mixed) override;
    void erase_group_level_table(TableKey table_key, size_t num_tables) override;
    void rename_group_level_table(TableKey table_key, StringData new_name) override;
    void insert_column(const Table*, ColKey col_key, DataType type, StringData name, Table* target_table) override;
    void erase_column(const Table*, ColKey col_key) override;
    void rename_column(const Table*, ColKey col_key, StringData name) override;

    void add_int(const Table*, ColKey col_key, ObjKey key, int_fast64_t value) override;
    void set(const Table*, ColKey col_key, ObjKey key, Mixed value, _impl::Instruction variant) override;

    void list_set(const CollectionBase& list, size_t list_ndx, Mixed value) override;
    void list_insert(const CollectionBase& list, size_t list_ndx, Mixed value) override;
    void list_move(const CollectionBase&, size_t from_link_ndx, size_t to_link_ndx) override;
    void list_erase(const CollectionBase&, size_t link_ndx) override;
    void list_clear(const CollectionBase&) override;

    void set_insert(const CollectionBase& list, size_t list_ndx, Mixed value) override;
    void set_erase(const CollectionBase& list, size_t list_ndx, Mixed value) override;
    void set_clear(const CollectionBase& list) override;

    void dictionary_insert(const CollectionBase&, size_t ndx, Mixed key, Mixed val) override;
    void dictionary_set(const CollectionBase&, size_t ndx, Mixed key, Mixed val) override;
    void dictionary_erase(const CollectionBase&, size_t ndx, Mixed key) override;

    void remove_object(const Table*, ObjKey) override;

    //@{

    /// Implicit nullifications due to removal of target row. This is redundant
    /// information from the point of view of replication, as the removal of the
    /// target row will reproduce the implicit nullifications in the target
    /// Realm anyway. The purpose of this instruction is to allow observers
    /// (reactor pattern) to be explicitly notified about the implicit
    /// nullifications.

    void nullify_link(const Table*, ColKey col_key, ObjKey key) override;
    void link_list_nullify(const Lst<ObjKey>&, size_t link_ndx) override;
    //@}

    template <class T>
    void emit(T instruction);

    // Returns true and populates m_last_table_name if instructions for the
    // table should be emitted.
    bool select_table(const Table&);

protected:
    // Replication interface:
    void do_initiate_transact(Group& group, version_type current_version, bool history_updated) override;

private:
    bool m_short_circuit = false;

    ChangesetEncoder m_encoder;
    DB* m_db = nullptr;
    Transaction* m_transaction;

    // Consistency checks:
    std::string m_table_being_erased;

    REALM_NORETURN void unsupported_instruction() const; // Throws TransformError

    // Returns true and populates m_last_class_name if instructions for the
    // owning table should be emitted.
    bool select_collection(const CollectionBase&); // returns true if table behavior != ignored

    InternString emit_class_name(StringData table_name);
    InternString emit_class_name(const Table& table);
    Instruction::Payload::Type get_payload_type(DataType) const;

    Instruction::Payload as_payload(Mixed value);
    Instruction::Payload as_payload(const CollectionBase& collection, Mixed value);
    Instruction::Payload as_payload(const Table& table, ColKey col_key, Mixed value);

    Instruction::PrimaryKey as_primary_key(Mixed);
    Instruction::PrimaryKey primary_key_for_object(const Table&, ObjKey key);
    void populate_path_instr(Instruction::PathInstruction&, const Table&, ObjKey key, ColKey field);
    void populate_path_instr(Instruction::PathInstruction&, const CollectionBase&);
    void populate_path_instr(Instruction::PathInstruction&, const CollectionBase&, uint32_t ndx);

    void dictionary_update(const CollectionBase&, const Mixed& key, const Mixed& val);

    // Cache information for the purpose of avoiding excessive string comparisons / interning
    // lookups.
    const Table* m_last_table = nullptr;
    ObjKey m_last_object;
    ColKey m_last_field;
    InternString m_last_class_name;
    util::Optional<Instruction::PrimaryKey> m_last_primary_key;
    InternString m_last_field_name;
};

inline void SyncReplication::set_short_circuit(bool b) noexcept
{
    m_short_circuit = b;
}

inline bool SyncReplication::is_short_circuited() const noexcept
{
    return m_short_circuit;
}

inline ChangesetEncoder& SyncReplication::get_instruction_encoder() noexcept
{
    return m_encoder;
}

inline const ChangesetEncoder& SyncReplication::get_instruction_encoder() const noexcept
{
    return m_encoder;
}

template <class T>
inline void SyncReplication::emit(T instruction)
{
    REALM_ASSERT(!m_short_circuit);
    m_encoder(instruction);
}


// Temporarily short-circuit replication
class TempShortCircuitReplication {
public:
    TempShortCircuitReplication(SyncReplication& bridge)
        : m_bridge(bridge)
    {
        m_was_short_circuited = bridge.is_short_circuited();
        bridge.set_short_circuit(true);
    }

    ~TempShortCircuitReplication()
    {
        m_bridge.set_short_circuit(m_was_short_circuited);
    }

    bool was_short_circuited() const noexcept
    {
        return m_was_short_circuited;
    }

private:
    SyncReplication& m_bridge;
    bool m_was_short_circuited;
};

} // namespace sync
} // namespace realm

#endif // REALM_SYNC_IMPL_INSTRUCTION_REPLICATION_HPP
