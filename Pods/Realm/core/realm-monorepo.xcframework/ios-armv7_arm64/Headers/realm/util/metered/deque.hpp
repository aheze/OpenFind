#ifndef REALM_UTIL_METERED_DEQUE_HPP
#define REALM_UTIL_METERED_DEQUE_HPP

#include <deque>
#include <realm/util/allocation_metrics.hpp>

namespace realm {
namespace util {
namespace metered {
/// Vector with metered allocation
template <class T, class Alloc = MeteredSTLAllocator<T>>
using deque = std::deque<T, Alloc>;
} // namespace metered
} // namespace util
} // namespace realm

#endif // REALM_UTIL_METERED_DEQUE_HPP
