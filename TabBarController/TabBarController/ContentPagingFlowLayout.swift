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
    
    /// get data
    var getTabs: (() -> [TabState])?
    
    var layoutAttributes = [UICollectionViewLayoutAttributes]()

    /// actual content offset used by `prepare`
    var currentOffset = CGFloat(0)
    
    /// old / new
    var focusedPageIndexChanged: ((Int?, Int?) -> Void)?
    
    /// index of focused/expanded cell
    var focusedPageIndex: Int?
   
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
        print("prep... \(collectionView.bounds.size)")
        
        
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
        print("set cont size to : \(contentSize)")
        self.layoutAttributes = layoutAttributes
        if !preparedOnce {
            preparedOnce = true
            
            /// get the target offset
            if let cameraOrigin = layoutAttributes[safe: 1]?.frame.origin {
                collectionView.contentOffset = cameraOrigin
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
        print("Bounds changed? \(boundsChanged)")
        context.invalidateFlowLayoutDelegateMetrics = boundsChanged
        return context
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        print("tar===============================================================================")
        return getTargetOffset(for: proposedContentOffset, velocity: velocity.x, updatePageIndex: true)
    }

    func getTargetOffset(for point: CGPoint, velocity: CGFloat, updatePageIndex: Bool = false) -> CGPoint {
        let proposedOffset = point.x

        let candidateOffsets = layoutAttributes.map { $0.frame.origin }
        var pickedOffsets = [CGPoint]()
        
        /// prevent scrolling from **photos -> lists** or **lists -> photos**
        let maxDistance = collectionView?.bounds.width ?? 500

        switch velocity {
        case _ where velocity < 0:
            pickedOffsets = candidateOffsets.filter( { $0.x <= proposedOffset })
        case _ where velocity > 0:
            pickedOffsets = candidateOffsets.filter( { $0.x >= proposedOffset })
        default:
            pickedOffsets = candidateOffsets
        }

        guard var (closestOriginIndex, closestOrigin) = pickedOffsets.enumerated().min(by: {
            return abs($0.element.x - proposedOffset) < abs($1.element.x - proposedOffset)
        }) else { /// `layoutAttributes` is empty
            return point
        }
        
        let distance = abs(closestOrigin.x - currentOffset)
        if distance > maxDistance {
            closestOriginIndex = 1 /// camera
            closestOrigin = candidateOffsets[closestOriginIndex]
        }
        
        if updatePageIndex {
            setFocusedPageIndex(closestOriginIndex)
        }
        return closestOrigin
    }
    
    func setFocusedPageIndex(_ index: Int, notify: Bool = false) {
        focusedPageIndex = index
        if notify {
            focusedPageIndexChanged?(focusedPageIndex, index)
        }
    }
}
