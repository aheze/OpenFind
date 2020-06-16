import Foundation

struct PagingDiff<T: PagingItem> where T: Hashable & Comparable {
  
  private let from: PagingItems<T>
  private let to: PagingItems<T>
  private var fromCache: [Int: T]
  private var toCache: [Int: T]
  private var lastMatchingItem: T?
  
  init(from: PagingItems<T>, to: PagingItems<T>) {
    self.from = from
    self.to = to
    self.fromCache = [:]
    self.toCache = [:]
    
    for item in from.items {
      fromCache[item.hashValue] = item
    }
    
    for item in to.items {
      toCache[item.hashValue] = item
    }
    
    for toItem in to.items {
      for fromItem in from.items {
        if toItem == fromItem {
          lastMatchingItem = toItem
          break
        }
      }
    }
  }
  
  func removed() -> [IndexPath] {
    let removed = diff(visibleItems: from, cache: toCache)
    var items: [IndexPath] = []
    
    if let lastItem = lastMatchingItem {
      for indexPath in removed {
        if let lastIndexPath = from.indexPath(for: lastItem) {
          if indexPath.item < lastIndexPath.item {
            items.append(indexPath)
          }
        }
      }
    }
    
    return items
  }
  
  func added() -> [IndexPath] {
    let removedCount = removed().count
    let added = diff(visibleItems: to, cache: fromCache)
    
    var items: [IndexPath] = []
    
    if let lastItem = lastMatchingItem {
      for indexPath in added {
        if let lastIndexPath = from.indexPath(for: lastItem) {
          if indexPath.item + removedCount <= lastIndexPath.item {
            items.append(indexPath)
          }
        }
      }
    }
    
    return items
  }
  
  private func diff(visibleItems: PagingItems<T>, cache: [Int: T]) -> [IndexPath] {
    #if swift(>=4.1)
      return visibleItems.items.compactMap { item in
        if cache[item.hashValue] == nil {
          return visibleItems.indexPath(for: item)
        }
        return nil
      }
    #else
      return visibleItems.items.flatMap { item in
        if cache[item.hashValue] == nil {
          return visibleItems.indexPath(for: item)
        }
        return nil
      }
    #endif
  }
  
}

