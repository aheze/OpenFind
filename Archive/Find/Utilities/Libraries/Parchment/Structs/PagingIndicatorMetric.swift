import Foundation
import UIKit

struct PagingIndicatorMetric {
    enum Inset {
        case left(CGFloat)
        case right(CGFloat)
        case both(CGFloat, CGFloat)
        case none
    }

    let frame: CGRect
    let insets: Inset
    let spacing: UIEdgeInsets

    var x: CGFloat {
        switch insets {
        case .left(let inset), .both(let inset, _):
            return frame.origin.x + max(inset, spacing.left)
        default:
            return frame.origin.x + spacing.left
        }
    }

    var width: CGFloat {
        switch insets {
        case .left(let inset):
            return frame.size.width - max(inset, spacing.left) - spacing.right
        case .right(let inset):
            return frame.size.width - max(inset, spacing.right) - spacing.left
        case .both(let insetLeft, let insetRight):
            return frame.size.width - max(insetRight, spacing.right) - max(insetLeft, spacing.left)
        case .none:
            return frame.size.width - spacing.left - spacing.right
        }
    }
}
