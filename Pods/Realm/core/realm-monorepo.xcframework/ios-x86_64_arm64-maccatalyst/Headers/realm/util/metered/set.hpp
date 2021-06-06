#ifndef REALM_UTIL_METERED_SET_HPP
#define REALM_UTIL_METERED_SET_HPP

#include <set>
#include <realm/util/allocation_metrics.hpp>

namespace realm {
namespace util {
namespace metered {
/// Set with metered allocation. Additionally, the default Compare is changed to
/// `std::less<>` instead of `std::less<K>`, which allows heterogenous lookup.
template <class T, class Compare = std::less<>, class Alloc = MeteredSTLAllocator<T>>
using set = std::set<T, Compare, Alloc>;
} // namespace metered
} // namespace util
} // namespace realm

#endif // REALM_UTIL_METERED_SET_HPP
