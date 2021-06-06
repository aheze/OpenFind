#ifndef REALM_UTIL_METERED_UNORDERED_MAP_HPP
#define REALM_UTIL_METERED_UNORDERED_MAP_HPP

#include <unordered_map>
#include <realm/util/allocation_metrics.hpp>

namespace realm {
namespace util {
namespace metered {
/// Unordered map with metered allocation
template <class K, class V, class Hash = std::hash<K>, class KeyEqual = std::equal_to<K>,
          class Alloc = MeteredSTLAllocator<std::pair<const K, V>>>
using unordered_map = std::unordered_map<K, V, Hash, KeyEqual, Alloc>;
} // namespace metered
} // namespace util
} // namespace realm

#endif // REALM_UTIL_METERED_UNORDERED_MAP_HPP
