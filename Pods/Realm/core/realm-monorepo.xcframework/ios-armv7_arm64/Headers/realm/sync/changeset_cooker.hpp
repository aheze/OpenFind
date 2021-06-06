
#include <realm/sync/config.hpp>

#ifndef REALM_SYNC_CHANGESET_COOKER_HPP
#define REALM_SYNC_CHANGESET_COOKER_HPP

namespace realm {
namespace sync {

/// Copy raw changesets unmodified.
class TrivialChangesetCooker : public ChangesetCooker {
public:
    bool cook_changeset(const Group&, const char* changeset, std::size_t changeset_size,
                        util::AppendBuffer<char>&) override;
};

} // namespace sync
} // namespace realm

#endif // REALM_SYNC_CHANGESET_COOKER_HPP
