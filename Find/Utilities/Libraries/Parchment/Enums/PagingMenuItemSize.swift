import Foundation
import UIKit

public enum PagingMenuItemSize {
    case fixed(width: CGFloat, height: CGFloat)

    // Automatically calculate the size of the menu items based on the
    // cells intrinsic content size. Try to come up with an estimated
    // width that's similar to the expected width of the cells.
    case selfSizing(estimatedWidth: CGFloat, height: CGFloat)

    // Tries to fit all menu items inside the bounds of the screen.
    // If the items can't fit, the items will scroll as normal and
    // set the menu items width to `minWidth`.
    case sizeToFit(minWidth: CGFloat, height: CGFloat)
}

public extension PagingMenuItemSize {
    var width: CGFloat {
        switch self {
        case .fixed(let width, _): return width
        case .sizeToFit(let minWidth, _): return minWidth
        case .selfSizing(let estimatedWidth, _): return estimatedWidth
        }
    }

    var height: CGFloat {
        switch self {
        case .fixed(_, let height): return height
        case .sizeToFit(_, let height): return height
        case .selfSizing(_, let height): return height
        }
    }
}
