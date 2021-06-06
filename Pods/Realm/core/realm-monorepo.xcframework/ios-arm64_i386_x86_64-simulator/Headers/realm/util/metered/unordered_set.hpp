#ifndef REALM_UTIL_METERED_UNORDERED_SET_HPP
#define REALM_UTIL_METERED_UNORDERED_SET_HPP

#include <unordered_set>
#include <realm/util/allocation_metrics.hpp>

namespace realm {
namespace util {
namespace metered {
/// Unordered set with metered allocation
template <class T, class Hash = std::hash<T>, class KeyEqual = std::equal_to<T>, class Alloc = MeteredSTLAllocator<T>>
using unordered_set = std::unordered_set<T, Hash, KeyEqual, Alloc>;
} // namespace metered
} // namespace util
} // namespace realm

#endif // REALM_UTIL_METERED_UNORDERED_SET_HPP
