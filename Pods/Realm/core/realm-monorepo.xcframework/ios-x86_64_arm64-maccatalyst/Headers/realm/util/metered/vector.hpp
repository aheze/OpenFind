#ifndef REALM_UTIL_METERED_VECTOR_HPP
#define REALM_UTIL_METERED_VECTOR_HPP

#include <vector>
#include <realm/util/allocation_metrics.hpp>

namespace realm {
namespace util {
namespace metered {
/// Vector with metered allocation
template <class T, class Alloc = MeteredSTLAllocator<T>>
using vector = std::vector<T, Alloc>;
} // namespace metered
} // namespace util
} // namespace realm

#endif // REALM_UTIL_METERED_VECTOR_HPP
