#ifndef REALM_UTIL_METERED_MAP_HPP
#define REALM_UTIL_METERED_MAP_HPP

#include <map>
#include <realm/util/allocation_metrics.hpp>

namespace realm {
namespace util {
namespace metered {
/// Map with metered allocation. Additionally, the default Compare is changed to
/// `std::less<>` instead of `std::less<K>`, which allows heterogenous lookup.
template <class K, class V, class Compare = std::less<>, class Alloc = MeteredSTLAllocator<std::pair<const K, V>>>
using map = std::map<K, V, Compare, Alloc>;
} // namespace metered
} // namespace util
} // namespace realm

#endif // REALM_UTIL_METERED_MAP_HPP
