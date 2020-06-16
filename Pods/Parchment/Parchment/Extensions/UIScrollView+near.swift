import UIKit

enum Edge {
  case left, right, top, bottom
}

extension UIScrollView {
  
  func near(edge: Edge, clearance: CGFloat = 0) -> Bool {
    switch edge {
    case .left:
      return contentOffset.x + contentInset.left - clearance <= 0
    case .right:
      return (contentOffset.x + bounds.width + clearance) >= contentSize.width
    case .top:
      return contentOffset.y + contentInset.top - clearance <= 0
    case .bottom:
      return (contentOffset.y + bounds.height + clearance) >= contentSize.height
    }
  }
  
}
