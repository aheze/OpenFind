
#ifndef REALM_SYNC_PERMISSIONS_HPP
#define REALM_SYNC_PERMISSIONS_HPP

#include <stddef.h>

namespace realm {
namespace sync {

/// The Privilege enum is intended to be used in a bitfield.
enum class Privilege : uint_least32_t {
    None = 0,

    /// The user can read the object (i.e. it can participate in the user's
    /// subscription.
    ///
    /// NOTE: On objects, it is a prerequisite that the object's class is also
    /// readable by the user.
    ///
    /// FIXME: Until we get asynchronous links, any object that is reachable
    /// through links from another readable/queryable object is also readable,
    /// regardless of whether the user specifically does not have read access.
    Read = 1,

    /// The user can modify the fields of the object.
    ///
    /// NOTE: On objects, it is a prerequisite that the object's class is also
    /// updatable by the user. When applied to a Class object, it does not
    /// imply that the user can modify the schema of the class, only the
    /// objects of that class.
    ///
    /// NOTE: This does not imply the SetPermissions privilege.
    Update = 2,

    /// The user can delete the object.
    ///
    /// NOTE: When applied to a Class object, it has no effect on whether
    /// objects of that class can be deleted by the user.
    ///
    /// NOTE: This implies the ability to implicitly nullify links pointing
    /// to the object from other objects, even if the user does not have
    /// permission to modify those objects in the normal way.
    Delete = 4,

    //@{
    /// The user can modify the object's permissions.
    ///
    /// NOTE: The user will only be allowed to assign permissions at or below
    /// their own privilege level.
    SetPermissions = 8,
    Share = SetPermissions,
    //@}

    /// When applied to a Class object, the user can query objects in that
    /// class.
    ///
    /// Has no effect when applied to objects other than Class.
    Query = 16,

    /// When applied to a Class object, the user may create objects in that
    /// class.
    ///
    /// NOTE: The user implicitly has Update and SetPermissions
    /// (but not necessarily Delete permission) within the same
    /// transaction as the object was created.
    ///
    /// NOTE: Even when a user has CreateObject rights, a CreateObject
    /// operation may still be rejected by the server, if the object has a
    /// primary key and the object already exists, but is not accessible by the
    /// user.
    Create = 32,

    /// When applied as a "Realm" privilege, the user can add classes and add
    /// columns to classes.
    ///
    /// NOTE: When applied to a class or object, this has no effect.
    ModifySchema = 64,

    ///
    /// Aggregate permissions for compatibility:
    ///
    Download = Read | Query,
    Upload = Update | Delete | Create,
    DeleteRealm = Upload, // FIXME: This seems overly permissive
};

inline constexpr uint_least32_t operator|(Privilege a, Privilege b)
{
    return static_cast<uint_least32_t>(a) | static_cast<uint_least32_t>(b);
}

inline constexpr uint_least32_t operator|(uint_least32_t a, Privilege b)
{
    return a | static_cast<uint_least32_t>(b);
}

inline constexpr uint_least32_t operator&(Privilege a, Privilege b)
{
    return static_cast<uint_least32_t>(a) & static_cast<uint_least32_t>(b);
}

inline constexpr uint_least32_t operator&(uint_least32_t a, Privilege b)
{
    return a & static_cast<uint_least32_t>(b);
}

inline uint_least32_t& operator|=(uint_least32_t& a, Privilege b)
{
    return a |= static_cast<uint_least32_t>(b);
}

inline constexpr uint_least32_t operator~(Privilege p)
{
    return ~static_cast<uint_least32_t>(p);
}

} // namespace sync
} // namespace realm


#endif // REALM_SYNC_PERMISSIONS_HPP
