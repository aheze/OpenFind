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

#ifndef REALM_LIST_NOTIFIER_HPP
#define REALM_LIST_NOTIFIER_HPP

#include <realm/object-store/impl/collection_notifier.hpp>

#include <realm/object-store/property.hpp>

#include <realm/collection.hpp>

namespace realm {
namespace _impl {
class ListNotifier : public CollectionNotifier {
public:
    ListNotifier(std::shared_ptr<Realm> realm, CollectionBase const& list, PropertyType type);

private:
    PropertyType m_type;
    std::unique_ptr<CollectionBase> m_list;

    TableKey m_table;
    ColKey m_col;
    ObjKey m_obj;

    // The last-seen size of the LinkView so that we can report row deletions
    // when the LinkView itself is deleted
    size_t m_prev_size;

    TransactionChangeInfo* m_info;

    void run() override;

    void do_attach_to(Transaction& sg) override;

    void release_data() noexcept override;
    bool do_add_required_change_info(TransactionChangeInfo& info) override;
};
} // namespace _impl
} // namespace realm

#endif // REALM_LIST_NOTIFIER_HPP
