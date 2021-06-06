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

#ifndef REALM_OS_COLLECTION_HPP
#define REALM_OS_COLLECTION_HPP

#include <realm/collection.hpp>
#include <realm/object-store/property.hpp>
#include <realm/object-store/util/copyable_atomic.hpp>
#include <realm/object-store/collection_notifications.hpp>
#include <realm/object-store/impl/collection_notifier.hpp>

namespace realm {
class Realm;
class Results;
class ObjectSchema;

namespace _impl {
class ListNotifier;
}

namespace object_store {
class Collection {
public:
    // The Collection object has been invalidated (due to the Realm being invalidated,
    // or the containing object being deleted)
    // All non-noexcept functions can throw this
    struct InvalidatedException : public std::logic_error {
        InvalidatedException()
            : std::logic_error("Access to invalidated List object")
        {
        }
    };

    // The input index parameter was out of bounds
    struct OutOfBoundsIndexException : public std::out_of_range {
        OutOfBoundsIndexException(size_t r, size_t c);
        size_t requested;
        size_t valid_count;
    };

    const std::shared_ptr<Realm>& get_realm() const
    {
        return m_realm;
    }
    // Get the type of the values contained in this List
    PropertyType get_type() const
    {
        return m_type;
    }

    virtual ~Collection();

    virtual Mixed get_any(size_t list_ndx) const = 0;
    virtual size_t find_any(Mixed value) const = 0;

    // Get the ObjectSchema of the values in this List
    // Only valid if get_type() returns PropertyType::Object
    const ObjectSchema& get_object_schema() const;

    ColKey get_parent_column_key() const;
    ObjKey get_parent_object_key() const;
    TableKey get_parent_table_key() const;

    size_t size() const;
    bool is_valid() const;
    void verify_attached() const;
    void verify_in_transaction() const;

    // Returns whether or not this Collection is frozen.
    bool is_frozen() const noexcept;

    // Return a Results representing a live view of this Collection.
    Results as_results() const;

    NotificationToken add_notification_callback(CollectionChangeCallback cb) &;

protected:
    std::shared_ptr<Realm> m_realm;
    PropertyType m_type;
    std::shared_ptr<CollectionBase> m_coll_base;
    mutable util::CopyableAtomic<const ObjectSchema*> m_object_schema = nullptr;
    _impl::CollectionNotifier::Handle<_impl::ListNotifier> m_notifier;


    Collection() noexcept;
    Collection(std::shared_ptr<Realm> r, const Obj& parent_obj, ColKey col);

    Collection(std::shared_ptr<Realm> r, const CollectionBase& coll);

    Collection(const Collection&);
    Collection& operator=(const Collection&);
    Collection(Collection&&);
    Collection& operator=(Collection&&);

    void verify_valid_row(size_t row_ndx, bool insertion = false) const;
    void validate(const Obj&) const;
};
} // namespace object_store
} // namespace realm

#endif /* REALM_OS_COLLECTION_HPP */
