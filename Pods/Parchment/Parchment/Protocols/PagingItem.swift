import Foundation

/// The `PagingItem` protocol is used to generate menu items for all
/// the view controllers, without having to actually allocate them
/// before they are needed. You can store whatever you want in here
/// that makes sense for what you're displaying. The only requirement
/// is that it conforms to `Hashable` and `Comparable`.
public protocol PagingItem {}

/// The `PagingTitleItem` protocol is used the `PagingTitleCell` to
/// store a title that is going to be display in the menu items.
public protocol PagingTitleItem: PagingItem {
  var title: String { get }
}
