import UIKit

extension UIEdgeInsets {
  
  var horizontal: CGFloat {
    return left + right
  }
  
  var vertical: CGFloat {
    return top + bottom
  }
  
}
