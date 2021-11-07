//
//  ContentPagingFlowLayout.swift
//  TabBarController
//
//  Created by Zheng on 11/2/21.
//


import UIKit

class ContentPagingFlowLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
    }
    
    /// prepared before?
    var preparedOnce = false
    
    var isInvalid = false
    
    /// get data
    var getTabs: (() -> [TabState])?
    
    
    var layoutAttributes = [UICollectionViewLayoutAttributes]()

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
        
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        var currentOrigin = CGFloat(0)
        
        guard let tabs = getTabs?() else { return }
        for index in tabs.indices {
            let rect = CGRect(x: currentOrigin, y: 0, width: width, height: height)
            let attribute = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: index, section: 0))
            attribute.frame = rect
            layoutAttributes.append(attribute)
            
            currentOrigin += width
        }

        
        self.contentSize = CGSize(width: currentOrigin, height: height)
        self.layoutAttributes = layoutAttributes
        if !preparedOnce {
            preparedOnce = true
            
            /// get the target offset
            if let cameraOrigin = layoutAttributes[safe: 1]?.frame.origin {
                collectionView.contentOffset = cameraOrigin
            }
        }
        if isInvalid {
            isInvalid = false
            if let targetPageOffset = layoutAttributes[safe: currentIndex]?.frame.origin {

                if currentOffset != targetPageOffset.x {
                    collectionView.contentOffset = targetPageOffset
                }
//                print("Offset is currently \(currentOffset), should be: \(targetPageOffset). IUndex: \(indexBeforeBoundsChange)")
            }
        }
        
        currentOffset = collectionView.contentOffset.x
    }
    
    /// boilerplate code
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool { return true }
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        let boundsChanged = newBounds.size != collectionView?.bounds.size
        
        context.invalidateFlowLayoutAttributes = boundsChanged
        context.invalidateFlowLayoutDelegateMetrics = boundsChanged
        
        if boundsChanged {
            isInvalid = true
        }
        return context
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        return getTargetOffset(for: proposedContentOffset, velocity: velocity.x)
    }

    func getTargetOffset(for point: CGPoint, velocity: CGFloat) -> CGPoint {
        let proposedOffset = point.x

        var pickedAttributes = [UICollectionViewLayoutAttributes?]()
        
        /// prevent scrolling from **photos -> lists** or **lists -> photos**
        let maxDistance = collectionView?.bounds.width ?? 500

        switch velocity {
        case _ where velocity < 0:
            pickedAttributes = layoutAttributes.map { layoutAttribute in
                let isCandidate = layoutAttribute.frame.origin.x <= proposedOffset
                return isCandidate ? layoutAttribute : nil
            }
        case _ where velocity > 0:
            pickedAttributes = layoutAttributes.map { layoutAttribute in
                let isCandidate = layoutAttribute.frame.origin.x >= proposedOffset
                return isCandidate ? layoutAttribute : nil
            }
        default:
            pickedAttributes = layoutAttributes
        }
        
        /// find closest origin
        var (closestAttribute, closestAttributeIndex, closestDistance): (UICollectionViewLayoutAttributes?, Int, CGFloat) = (nil, 0, CGFloat.infinity)
        for (index, attribute) in pickedAttributes.enumerated() {
            if let layoutAttribute = attribute {
                let distance = abs(layoutAttribute.frame.origin.x - proposedOffset)
                if distance < closestDistance {
                    closestAttributeIndex = index
                    closestAttribute = layoutAttribute
                    closestDistance = distance /// for keeping track later
                }
            }
        }
        
        if let closestAttributeUnwrapped = closestAttribute, velocity != 0 {
            let distance = abs(closestAttributeUnwrapped.frame.origin.x - currentOffset)
            if distance > maxDistance {
                closestAttributeIndex = 1 /// camera
                closestAttribute = layoutAttributes[closestAttributeIndex]
            }
        }
        
        currentIndex = closestAttributeIndex
        return closestAttribute?.frame.origin ?? point
    }
}
