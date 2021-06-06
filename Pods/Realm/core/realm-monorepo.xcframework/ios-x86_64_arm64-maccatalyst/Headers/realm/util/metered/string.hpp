#ifndef REALM_UTIL_METERED_STRING_HPP
#define REALM_UTIL_METERED_STRING_HPP

#include <string>
#include <realm/util/allocation_metrics.hpp>

namespace realm {
namespace util {
namespace metered {
/// String with metered allocation
using string = std::basic_string<char, std::char_traits<char>, MeteredSTLAllocator<char>>;
} // namespace metered
} // namespace util
} // namespace realm

#endif // REALM_UTIL_METERED_STRING_HPP
