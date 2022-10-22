import Foundation

/// The `PagingItem` protocol is used to generate menu items for all
/// the view controllers, without having to actually allocate them
/// before they are needed. You can store whatever you want in here
/// that makes sense for what you're displaying.
public protocol PagingItem {
    var identifier: Int { get }
    func isEqual(to item: PagingItem) -> Bool
    func isBefore(item: PagingItem) -> Bool
}

public extension PagingItem where Self: Equatable {
    func isEqual(to item: PagingItem) -> Bool {
        guard let item = item as? Self else { return false }
        return self == item
    }
}

public extension PagingItem where Self: Comparable {
    func isBefore(item: PagingItem) -> Bool {
        guard let item = item as? Self else { return false }
        return self < item
    }
}

public extension PagingItem where Self: Hashable {
    var identifier: Int {
        return hashValue
    }
}
