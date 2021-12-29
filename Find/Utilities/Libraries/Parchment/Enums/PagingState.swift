import Foundation
import UIKit

/// The current state of the menu items. Indicates whether an item
/// is currently selected or is scrolling to another item. Can be
/// used to get the distance and progress of any ongoing transition.
public enum PagingState: Equatable {
    case empty
    case selected(pagingItem: PagingItem)
    case scrolling(
        pagingItem: PagingItem,
        upcomingPagingItem: PagingItem?,
        progress: CGFloat,
        initialContentOffset: CGPoint,
        distance: CGFloat
    )
}

public extension PagingState {
    var currentPagingItem: PagingItem? {
        switch self {
        case .empty:
            return nil
        case .scrolling(let pagingItem, _, _, _, _):
            return pagingItem
        case .selected(let pagingItem):
            return pagingItem
        }
    }

    var upcomingPagingItem: PagingItem? {
        switch self {
        case .empty:
            return nil
        case .scrolling(_, let upcomingPagingItem, _, _, _):
            return upcomingPagingItem
        case .selected:
            return nil
        }
    }

    var progress: CGFloat {
        switch self {
        case .scrolling(_, _, let progress, _, _):
            return progress
        case .selected, .empty:
            return 0
        }
    }

    var distance: CGFloat {
        switch self {
        case .scrolling(_, _, _, _, let distance):
            return distance
        case .selected, .empty:
            return 0
        }
    }

    var visuallySelectedPagingItem: PagingItem? {
        if abs(progress) > 0.5 {
            return upcomingPagingItem ?? currentPagingItem
        } else {
            return currentPagingItem
        }
    }
}

public func == (lhs: PagingState, rhs: PagingState) -> Bool {
    switch (lhs, rhs) {
    case
        (let .scrolling(lhsCurrent, lhsUpcoming, lhsProgress, lhsOffset, lhsDistance),
         .scrolling(let rhsCurrent, let rhsUpcoming, let rhsProgress, let rhsOffset, let rhsDistance)):
        if lhsCurrent.isEqual(to: rhsCurrent),
           lhsProgress == rhsProgress,
           lhsOffset == rhsOffset,
           lhsDistance == rhsDistance
        {
            if let lhsUpcoming = lhsUpcoming, let rhsUpcoming = rhsUpcoming, lhsUpcoming.isEqual(to: rhsUpcoming) {
                return true
            } else if lhsUpcoming == nil, rhsUpcoming == nil {
                return true
            }
        }
        return false
    case (.selected(let a), .selected(let b)) where a.isEqual(to: b):
        return true
    case (.empty, .empty):
        return true
    default:
        return false
    }
}
