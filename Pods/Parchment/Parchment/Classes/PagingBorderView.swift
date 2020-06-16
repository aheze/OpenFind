import UIKit

/// A custom `UICollectionViewReusableView` subclass used to display
/// the border at the bottom of the menu items. You can subclass this
/// type if you need further customization; just override the
/// `borderClass` property in `PagingViewController`.
open class PagingBorderView: UICollectionReusableView {
  
  override open func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
    super.apply(layoutAttributes)
    if let attributes = layoutAttributes as? PagingBorderLayoutAttributes {
      backgroundColor = attributes.backgroundColor
    }
  }
  
}
