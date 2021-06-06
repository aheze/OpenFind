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

#ifndef REALM_SYNC_OBJECT_HPP
#define REALM_SYNC_OBJECT_HPP

#include <realm/util/logger.hpp>
#include <realm/table_ref.hpp>
#include <realm/string_data.hpp>
#include <realm/group.hpp>

#include <realm/sync/object_id.hpp>

#include <vector>

/// This file presents a convenience API for making changes to a Realm file that
/// adhere to the conventions of assigning stable IDs to every object.

namespace realm {

class Group;
class ReadTransaction;
class WriteTransaction;

namespace sync {

class SyncHistory;

/// Determine whether the Group has a sync-type history, and therefore whether
/// it supports globally stable object IDs.
///
/// The Group does not need to be in a transaction.
bool has_object_ids(const Table&);

/// Determine whether object IDs for objects without primary keys are globally
/// stable. This is true if and only if the Group has been in touch with the
/// server (or is the server), and will remain true forever thereafter.
///
/// It is an error to call this function for groups that do not have object IDs
/// (i.e. where `has_object_ids()` returns false).
///
/// The Group is assumed to be in a read transaction.
bool is_object_id_stability_achieved(const DB&, const Transaction&);

/// Create a table with an object ID column.
///
/// It is an error to add tables to Groups with a sync history type directly.
/// This function or related functions must be used instead.
///
/// The resulting table will be born with 1 column, which is a column used
/// in the maintenance of object IDs.
///
/// NOTE: The table name must begin with the prefix "class_" in accordance with
/// Object Store conventions.
///
/// The Group must be in a write transaction.
inline TableRef create_table(Transaction& wt, StringData name)
{
    return wt.get_or_add_table(name);
}

/// Create a table with an object ID column and a primary key column.
///
/// It is an error to add tables to Groups with a sync history type directly.
/// This function or related functions must be used instead.
///
/// The resulting table will be born with 2 columns, which is a column used
/// in the maintenance of object IDs and the requested primary key column.
/// The primary key column must have either integer or string type, and it
/// will be given the name provided in the argument \a pk_column_name.
///
/// The 'pk' metadata table is updated with information about the primary key
/// column. If the 'pk' table does not yet exist, it is created.
///
/// Please note: The 'pk' metadata table will not be synchronized directly,
/// so subsequent updates to it will be lost (as they constitute schema-breaking
/// changes).
///
/// NOTE: The table name must begin with the prefix "class_" in accordance with
/// Object Store conventions.
///
/// The Group must be in a write transaction.
inline TableRef create_table_with_primary_key(Transaction& wt, StringData name, DataType pk_type,
                                              StringData pk_column_name, bool nullable = false)
{
    if (TableRef table = wt.get_table(name)) {
        if (!table->get_primary_key_column() ||
            table->get_column_name(table->get_primary_key_column()) != pk_column_name ||
            table->is_nullable(table->get_primary_key_column()) != nullable) {
            throw std::runtime_error("Inconsistent schema");
        }
        return table;
    }
    return wt.add_table_with_primary_key(name, pk_type, pk_column_name, nullable);
}


//@{
/// Erase table and update metadata.
///
/// It is an error to erase tables via the Group API, because it does not
/// correctly update metadata tables (such as the `pk` table).
void erase_table(Transaction&, StringData name);
void erase_table(Transaction&, TableRef);
//@}

/// Create an array column with the specified element type.
///
/// The result will be a column of type type_Table with one subcolumn named
/// "!ARRAY_VALUE" of the specified element type and nullability.
///
/// Return the column index of the inserted array column.
ColKey add_array_column(Table&, DataType element_type, StringData column_name, bool is_nullable = false);


/// Determine whether it is safe to call `object_id_for_row()` on tables without
/// primary keys. If the table has a primary key, always returns true.
bool has_globally_stable_object_ids(const Table&);

bool table_has_primary_key(const Table&);

PrimaryKey primary_key_for_row(const Table&, ObjKey);
PrimaryKey primary_key_for_row(const Obj&);

/// Get the index of the row with the object ID.
///
/// \returns realm::npos if the object does not exist in the table.
ObjKey row_for_object_id(const Table&, GlobalKey);
Obj obj_for_object_id(const Table&, GlobalKey);

ObjKey row_for_primary_key(const Table&, PrimaryKey);
Obj obj_for_primary_key(const Table&, PrimaryKey);

/// Migrate a server-side Realm file whose history type is
/// `Replication::hist_SyncServer` and whose history schema version is 0 (i.e.,
/// Realm files without stable identifiers).
void import_from_legacy_format(const Group& old_group, Group& new_group, util::Logger&);

using TableNameBuffer = std::array<char, Group::max_table_name_length>;
StringData table_name_to_class_name(StringData);
StringData class_name_to_table_name(StringData, TableNameBuffer&);


// Implementation:

inline StringData table_name_to_class_name(StringData table_name)
{
    REALM_ASSERT(table_name.begins_with("class_"));
    return table_name.substr(6);
}


inline StringData class_name_to_table_name(StringData class_name, TableNameBuffer& buffer)
{
    constexpr const char class_prefix[] = "class_";
    constexpr size_t class_prefix_len = sizeof(class_prefix) - 1;
    char* p = std::copy_n(class_prefix, class_prefix_len, buffer.data());
    size_t len = std::min(class_name.size(), buffer.size() - class_prefix_len);
    std::copy_n(class_name.data(), len, p);
    return StringData(buffer.data(), class_prefix_len + len);
}

} // namespace sync
} // namespace realm

#endif // REALM_SYNC_OBJECT_HPP
