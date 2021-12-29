//
//  ContentPagingFlowLayout.swift
//  TabBarController
//
//  Created by Zheng on 11/2/21.
//

import UIKit

open class PageLayoutAttributes: UICollectionViewLayoutAttributes {
    var fullOrigin = CGFloat(0) /// origin when expanded
    
    override open func copy(with zone: NSZone?) -> Any {
        let copy = super.copy(with: zone) as! Self
        copy.fullOrigin = fullOrigin
        
        return copy
    }
    
    override open func isEqual(_ object: Any?) -> Bool {
        guard let attributes = object as? Self else { return false }
        guard
            attributes.fullOrigin == fullOrigin
        else { return false }
    
        return super.isEqual(object)
    }
}

class ContentPagingFlowLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
    }
    
    /// prepared before?
    var preparedOnce = false
    
    /// get data
    var getTabs: (() -> [TabState])?
    
    var layoutAttributes = [PageLayoutAttributes]()

    /// actual content offset used by `prepare`
    var currentOffset = CGFloat(0)
   
    /// calculated from `getTargetOffset`
    var currentIndex = 1
    
    var contentSize = CGSize.zero /// the scrollable content size of the collection view
    override var collectionViewContentSize: CGSize { return contentSize } /// pass scrollable content size back to the collection view
    
    /// pass attributes to the collection view flow layout
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributes[safe: indexPath.item]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        /// edge cells don't shrink, but the animation is perfect
        return layoutAttributes.filter { rect.intersects($0.frame) } /// try deleting this line
    }
    
    /// make the layout (strip vs list) here
    override func prepare() { /// configure the cells' frames
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        
        let width = collectionView.bounds.width
        let height = collectionView.bounds.height
        
        var layoutAttributes = [PageLayoutAttributes]()
        var currentOrigin = CGFloat(0)
        
        if !preparedOnce {
            preparedOnce = true
            collectionView.contentOffset.x = width /// start at camera
        }
        
        guard let tabs = getTabs?() else { return }
        for index in tabs.indices {
            let attribute = PageLayoutAttributes(forCellWith: IndexPath(item: index, section: 0))
            
            let rect: CGRect
            if index == 1 {
                rect = CGRect(x: collectionView.contentOffset.x, y: 0, width: width, height: height)
                attribute.zIndex = 1
            } else {
                rect = CGRect(x: currentOrigin, y: 0, width: width, height: height)
                attribute.zIndex = 2
            }
            
            attribute.fullOrigin = currentOrigin
            attribute.frame = rect
            layoutAttributes.append(attribute)
            
            currentOrigin += width
        }

        contentSize = CGSize(width: currentOrigin, height: height)
        self.layoutAttributes = layoutAttributes
        
        currentOffset = collectionView.contentOffset.x
    }
    
    /// boilerplate code
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool { return true }
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        let boundsChanged = newBounds.size != collectionView?.bounds.size
        context.invalidateFlowLayoutAttributes = boundsChanged
        context.invalidateFlowLayoutDelegateMetrics = boundsChanged
        return context
    }
    
    /// called upon finger lift
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        return getTargetOffset(for: proposedContentOffset, velocity: velocity.x)
    }
    
    /// called after rotation
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        let attributes = layoutAttributes[safe: currentIndex]
        return CGPoint(x: attributes?.fullOrigin ?? proposedContentOffset.x, y: 0)
    }
    
    func getTargetOffset(for point: CGPoint, velocity: CGFloat) -> CGPoint {
        let proposedOffset = point.x

        var pickedAttributes = [PageLayoutAttributes?]()
        
        /// prevent scrolling from **photos -> lists** or **lists -> photos**
        let maxDistance = collectionView?.bounds.width ?? 500

        switch velocity {
        case _ where velocity < 0:
            pickedAttributes = layoutAttributes.map { layoutAttribute in
                let isCandidate = layoutAttribute.fullOrigin <= proposedOffset
                return isCandidate ? layoutAttribute : nil
            }
        case _ where velocity > 0:
            pickedAttributes = layoutAttributes.map { layoutAttribute in
                let isCandidate = layoutAttribute.fullOrigin >= proposedOffset
                return isCandidate ? layoutAttribute : nil
            }
        default:
            pickedAttributes = layoutAttributes
        }
        
        /// find closest origin
        var (closestAttribute, closestAttributeIndex, closestDistance): (PageLayoutAttributes?, Int, CGFloat) = (nil, 0, CGFloat.infinity)
        for (index, attribute) in pickedAttributes.enumerated() {
            if let layoutAttribute = attribute {
                let distance = abs(layoutAttribute.fullOrigin - proposedOffset)
                if distance < closestDistance {
                    closestAttributeIndex = index
                    closestAttribute = layoutAttribute
                    closestDistance = distance /// for keeping track later
                }
            }
        }
        
        if let closestAttributeUnwrapped = closestAttribute, velocity != 0 {
            let distance = abs(closestAttributeUnwrapped.fullOrigin - currentOffset)
            if distance > maxDistance {
                closestAttributeIndex = 1 /// camera
                closestAttribute = layoutAttributes[closestAttributeIndex]
            }
        }
        
        currentIndex = closestAttributeIndex
        return CGPoint(x: closestAttribute?.fullOrigin ?? point.x, y: 0)
    }
}
