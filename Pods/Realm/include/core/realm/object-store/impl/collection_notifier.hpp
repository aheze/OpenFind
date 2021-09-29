////////////////////////////////////////////////////////////////////////////
//
// Copyright 2016 Realm Inc.
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

#ifndef REALM_BACKGROUND_COLLECTION_HPP
#define REALM_BACKGROUND_COLLECTION_HPP

#include <realm/object-store/impl/deep_change_checker.hpp>
#include <realm/object-store/util/checked_mutex.hpp>

#include <realm/util/assert.hpp>
#include <realm/version_id.hpp>
#include <realm/table_ref.hpp>

#include <array>
#include <atomic>
#include <exception>
#include <functional>
#include <mutex>
#include <unordered_set>

namespace realm {
namespace _impl {

// A `NotificationCallback` is added to a collection when observing it.
// It contains all information necessary in case we need to notify about changes
// to this collection.
struct NotificationCallback {
    // The callback function being invoked when we notify for changes in this collection.
    CollectionChangeCallback fn;
    // The pending changes accumulated on the worker thread. This field is
    // guarded by m_callback_mutex and is written to on the worker thread,
    // then read from on the target thread.
    CollectionChangeBuilder accumulated_changes;
    // The changeset which will actually be passed to `fn`. This field is
    // not guarded by a lock and can only be accessed on the notifier's
    // target thread.
    CollectionChangeBuilder changes_to_deliver;
    // The filter that this `NotificationCallback` is restricted to.
    // If not empty, modifications of elements not part of the `key_path_array`
    // will not invoke a notification.
    KeyPathArray key_path_array = {};
    // A unique-per-notifier identifier used to unregister the callback.
    uint64_t token = 0;
    // We normally want to skip calling the callback if there's no changes,
    // but only if we've sent the initial notification (to support the
    // async query use-case). Not guarded by a mutex and is only readable
    // on the target thread.
    bool initial_delivered = false;
    // Set within a write transaction on the target thread if this callback
    // should not be called with changes for that write. requires m_callback_mutex.
    bool skip_next = false;
};

// A base class for a notifier that keeps a collection up to date and/or
// generates detailed change notifications on a background thread. This manages
// most of the lifetime-management issues related to sharing an object between
// the worker thread and the collection on the target thread, along with the
// thread-safe callback collection.
class CollectionNotifier {
public:
    CollectionNotifier(std::shared_ptr<Realm>);
    virtual ~CollectionNotifier();

    // ------------------------------------------------------------------------
    // Public API for the collections using this to get notifications:

    // Stop receiving notifications from this background worker
    // This must be called in the destructor of the collection
    void unregister() noexcept;

    /**
     * Add a callback to be called each time the collection changes.
     * This can only be called from the target collection's thread.
     *
     * @param callback The `CollectionChangeCallback` that will be executed when a change happens.
     * @param key_path_array An array of all key paths that should be filtered for. If a changed
     *                       table/column combination is not part of the `key_path_array`, no
     *                       notification will be sent.
     *
     * @return A token which can be passed to `remove_callback()`.
     */
    uint64_t add_callback(CollectionChangeCallback callback, KeyPathArray key_path_array) REQUIRES(!m_callback_mutex);

    /**
     * Remove a previously added token.
     * The token is no longer valid after calling this function and must not be used again.
     * This function can be called from any thread.
     *
     * @param token The token that was genereted and returned from `add_callback` is used in this function
     *              to identify the callback that is supposed to be removed.
     */
    void remove_callback(uint64_t token) REQUIRES(!m_callback_mutex);

    void suppress_next_notification(uint64_t token) REQUIRES(!m_callback_mutex);

    // ------------------------------------------------------------------------
    // API for RealmCoordinator to manage running things and calling callbacks

    bool is_for_realm(Realm&) const noexcept;
    Realm* get_realm() const noexcept
    {
        return m_realm.get();
    }

    // Get the Transaction version which this collection can attach to (if it's
    // in handover mode), or can deliver to (if it's been handed over to the BG worker alredad)
    // precondition: RealmCoordinator::m_notifier_mutex is locked
    VersionID version() const noexcept
    {
        return m_sg_version;
    }

    // Release references to all core types
    // This is called on the worker thread to ensure that non-thread-safe things
    // can be destroyed on the correct thread, even if the last reference to the
    // CollectionNotifier is released on a different thread
    virtual void release_data() noexcept;

    // Prepare to deliver the new collection and call callbacks.
    // Returns whether or not it has anything to deliver.
    // precondition: RealmCoordinator::m_notifier_mutex is locked
    bool package_for_delivery() REQUIRES(!m_callback_mutex);

    // Pass the given error to all registered callbacks, then remove them
    // precondition: RealmCoordinator::m_notifier_mutex is unlocked
    void deliver_error(std::exception_ptr) REQUIRES(!m_callback_mutex);

    // Call each of the given callbacks with the changesets prepared by package_for_delivery()
    // precondition: RealmCoordinator::m_notifier_mutex is unlocked
    void before_advance() REQUIRES(!m_callback_mutex);
    void after_advance() REQUIRES(!m_callback_mutex);

    bool is_alive() const noexcept;

    // precondition: RealmCoordinator::m_notifier_mutex is locked *or* is called on worker thread
    bool has_run() const noexcept
    {
        return m_has_run;
    }

    // Attach the handed-over query to `sg`. Must not be already attached to a Transaction.
    // precondition: RealmCoordinator::m_notifier_mutex is locked
    void attach_to(std::shared_ptr<Transaction> sg);

    // Set `info` as the new ChangeInfo that will be populated by the next
    // transaction advance, and register all required information in it
    // precondition: RealmCoordinator::m_notifier_mutex is locked
    void add_required_change_info(TransactionChangeInfo& info);

    // precondition: RealmCoordinator::m_notifier_mutex is unlocked
    virtual void run() = 0;

    // precondition: RealmCoordinator::m_notifier_mutex is locked
    void prepare_handover() REQUIRES(!m_callback_mutex);

    template <typename T>
    class Handle;

    bool have_callbacks() const noexcept
    {
        return m_have_callbacks;
    }

protected:
    void add_changes(CollectionChangeBuilder change) REQUIRES(!m_callback_mutex);
    std::unique_lock<std::mutex> lock_target();
    Transaction& source_shared_group();
    // signal that the underlying source object of the collection has been deleted
    // but only report this to the notifiers the first time this is reported
    void report_collection_root_is_deleted();

    bool any_related_table_was_modified(TransactionChangeInfo const&) const noexcept;

    // Creates and returns a `DeepChangeChecker` or `KeyPathChecker` depending on the given KeyPathArray.
    std::function<bool(ObjectChangeSet::ObjectKeyType)> get_modification_checker(TransactionChangeInfo const&,
                                                                                 ConstTableRef)
        REQUIRES(!m_callback_mutex);

    // Creates and returns a `ObjectKeyPathChangeChecker` which behaves slightly different that `DeepChangeChecker`
    // and `KeyPathChecker` which are used for `Collection`s.
    std::function<std::vector<int64_t>(ObjectChangeSet::ObjectKeyType)>
    get_object_modification_checker(TransactionChangeInfo const&, ConstTableRef) REQUIRES(!m_callback_mutex);

    // Returns a vector containing all `KeyPathArray`s from all `NotificationCallback`s attached to this notifier.
    void recalculate_key_path_array() REQUIRES(m_callback_mutex);
    // Checks `KeyPathArray` filters on all `m_callbacks` and returns true if at least one key path
    // filter is attached to each of them.
    bool any_callbacks_filtered() const noexcept;
    // Checks `KeyPathArray` filters on all `m_callbacks` and returns true if at least one key path
    // filter is attached to all of them.
    bool all_callbacks_filtered() const noexcept;

    void update_related_tables(Table const& table) REQUIRES(m_callback_mutex);

    // A summary of all `KeyPath`s attached to the `m_callbacks`.
    KeyPathArray m_key_path_array;

    // The actual change, calculated in run() and delivered in prepare_handover()
    CollectionChangeBuilder m_change;

    // A vector of all tables related to this table (including itself).
    std::vector<DeepChangeChecker::RelatedTable> m_related_tables;

    // Due to the keypath filtered notifications we need to update the related tables every time the callbacks do see
    // a change since the list of related tables is filtered by the key paths used for the notifications.
    bool m_did_modify_callbacks = true;

    // Currently registered callbacks and a mutex which must always be held
    // while doing anything with them or m_callback_index
    util::CheckedMutex m_callback_mutex;

private:
    virtual void do_attach_to(Transaction&) {}
    virtual void do_prepare_handover(Transaction&) {}
    virtual bool do_add_required_change_info(TransactionChangeInfo&) = 0;
    virtual bool prepare_to_deliver()
    {
        return true;
    }
    // Iterate over m_callbacks and call the given function on each one. This
    // does fancy locking things to allow fn to drop the lock before invoking
    // the callback (which must be done to avoid deadlocks).
    template <typename Fn>
    void for_each_callback(Fn&& fn) REQUIRES(!m_callback_mutex);

    std::vector<NotificationCallback>::iterator find_callback(uint64_t token);

    mutable std::mutex m_realm_mutex;
    std::shared_ptr<Realm> m_realm;

    VersionID m_sg_version;
    std::shared_ptr<Transaction> m_sg;

    bool m_has_run = false;
    bool m_error = false;
    bool m_has_delivered_root_deletion_event = false;

    // Cached check for if callbacks have keypath filters which can be used
    // only on the worker thread, but without acquiring the callback mutex
    bool m_all_callbacks_filtered = false;
    bool m_any_callbacks_filtered = false;

    // All `NotificationCallback`s added to this `CollectionNotifier` via `add_callback()`.
    std::vector<NotificationCallback> m_callbacks;

    // Cached value for if m_callbacks is empty, needed to avoid deadlocks in
    // run() due to lock-order inversion between m_callback_mutex and m_target_mutex
    // It's okay if this value is stale as at worst it'll result in us doing
    // some extra work.
    std::atomic<bool> m_have_callbacks = {false};

    // Iteration variable for looping over callbacks. remove_callback() will
    // sometimes update this to ensure that removing a callback while iterating
    // over the callbacks will not skip an unrelated callback.
    size_t m_callback_index GUARDED_BY(m_callback_mutex) = -1;
    // The number of callbacks which were present when the notifier was packaged
    // for delivery which are still present.
    // Updated by packaged_for_delivery and remove_callback(), and used in
    // for_each_callback() to avoid calling callbacks registered during delivery.
    size_t m_callback_count GUARDED_BY(m_callback_mutex) = -1;

    uint64_t m_next_token GUARDED_BY(m_callback_mutex) = 0;
};

// A smart pointer to a CollectionNotifier that unregisters the notifier when
// the pointer is destroyed. Movable. Copying will produce a null Handle.
template <typename T>
class CollectionNotifier::Handle : public std::shared_ptr<T> {
public:
    using std::shared_ptr<T>::shared_ptr;

    Handle() = default;
    ~Handle()
    {
        reset();
    }

    // Copying a Handle produces a null Handle.
    Handle(const Handle&)
        : Handle()
    {
    }
    Handle& operator=(const Handle& other)
    {
        if (this != &other) {
            reset();
        }
        return *this;
    }

    Handle(Handle&&) = default;
    Handle& operator=(Handle&& other)
    {
        reset();
        std::shared_ptr<T>::operator=(std::move(other));
        return *this;
    }

    template <typename U>
    Handle& operator=(std::shared_ptr<U>&& other)
    {
        reset();
        std::shared_ptr<T>::operator=(std::move(other));
        return *this;
    }

    void reset()
    {
        if (*this) {
            this->get()->unregister();
            std::shared_ptr<T>::reset();
        }
    }
};

// A package of CollectionNotifiers for a single Realm instance which is passed
// around to the various places which need to actually trigger the notifications
class NotifierPackage {
public:
    NotifierPackage() = default;
    NotifierPackage(std::exception_ptr error, std::vector<std::shared_ptr<CollectionNotifier>> notifiers,
                    RealmCoordinator* coordinator);

    explicit operator bool() const noexcept
    {
        return !m_notifiers.empty();
    }

    // Get the version which this package can deliver into, or VersionID{} if
    // it has not yet been packaged
    util::Optional<VersionID> version() const noexcept
    {
        return m_version;
    }

    // If a version is given, block until notifications are ready for that
    // version, and then regardless of whether or not a version was given filter
    // the notifiers to just the ones which have anything to deliver.
    // No-op if called multiple times
    void package_and_wait(util::Optional<VersionID::version_type> target_version);

    // Send the before-change notifications
    void before_advance();
    // Deliver the payload associated with the contained notifiers and/or the error
    void deliver(Transaction& sg);
    // Send the after-change notifications
    void after_advance();

private:
    util::Optional<VersionID> m_version;
    std::vector<std::shared_ptr<CollectionNotifier>> m_notifiers;

    RealmCoordinator* m_coordinator = nullptr;
    std::exception_ptr m_error;
};

} // namespace _impl
} // namespace realm

#endif /* REALM_BACKGROUND_COLLECTION_HPP */
