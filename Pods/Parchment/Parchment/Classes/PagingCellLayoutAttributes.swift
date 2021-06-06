import UIKit

/// A custom `UICollectionViewLayoutAttributes` subclass that adds a
/// `progress` property indicating how far the user has scrolled.
open class PagingCellLayoutAttributes: UICollectionViewLayoutAttributes {
  
  open var progress: CGFloat = 0.0
  
  override open func copy(with zone: NSZone? = nil) -> Any {
    let copy = super.copy(with: zone) as! PagingCellLayoutAttributes
    copy.progress = progress
    return copy
  }
  
  override open func isEqual(_ object: Any?) -> Bool {
    if let rhs = object as? PagingCellLayoutAttributes {
      if progress != rhs.progress {
        return false
      }
      return super.isEqual(object)
    } else {
      return false
    }
  }

}
