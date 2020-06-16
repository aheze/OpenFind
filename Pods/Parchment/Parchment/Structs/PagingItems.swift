import Foundation

/// A data structure used to hold an array of `PagingItem`'s, with
/// methods for getting the index path for a given `PagingItem` and
/// vice versa.
public struct PagingItems<T: PagingItem> where T: Hashable & Comparable {
  
  /// A sorted array of the currently visible `PagingItem`'s.
  public let items: [T]
  
  let hasItemsBefore: Bool
  let hasItemsAfter: Bool
  let itemsCache: Set<T>
  
  init(items: [T], hasItemsBefore: Bool = false, hasItemsAfter: Bool = false) {
    self.items = items
    self.hasItemsBefore = hasItemsBefore
    self.hasItemsAfter = hasItemsAfter
    self.itemsCache = Set(items)
  }
  
  /// The `IndexPath` for a given `PagingItem`. Returns nil if the
  /// `PagingItem` is not in the `items` array.
  ///
  /// - Parameter pagingItem: A `PagingItem` instance
  /// - Returns: The `IndexPath` for the given `PagingItem`
  public func indexPath(for pagingItem: T) -> IndexPath? {
    guard let index = items.firstIndex(of: pagingItem) else { return nil }
    return IndexPath(item: index, section: 0)
  }
  
  /// The `PagingItem` for a given `IndexPath`. This method will crash
  /// if you pass in an `IndexPath` that is currently not visible in
  /// the collection view.
  ///
  /// - Parameter indexPath: An `IndexPath` that is currently visible
  /// - Returns: The `PagingItem` for the given `IndexPath`
  public func pagingItem(for indexPath: IndexPath) -> T {
    return items[indexPath.item]
  }
  
  /// The direction from a given `PagingItem` to another `PagingItem`.
  /// If the `PagingItem`'s are equal the direction will be .none.
  ///
  /// - Parameter from: The current `PagingItem`
  /// - Parameter to: The `PagingItem` being scrolled towards
  /// - Returns: The `PagingDirection` for a given `PagingItem`
  public func direction(from: T, to: T) -> PagingDirection {
    if itemsCache.contains(from) == false {
      return .none
    } else if to > from {
      return .forward
    } else if to < from {
      return .reverse
    }
    return .none
  }
}
