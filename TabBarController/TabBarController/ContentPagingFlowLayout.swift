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
    var getTabs: (() -> [TabType])?
    
    var layoutAttributes = [UICollectionViewLayoutAttributes]()
    

    /// actual content offset used by `prepare`
    var currentOffset = CGFloat(0)
    
    /// old / new
    var focusedPageIndexChanged: ((Int?, Int?) -> Void)?
    
    /// index of focused/expanded cell
    var focusedPageIndex: Int? {
        didSet {
            focusedPageIndexChanged?(oldValue, focusedPageIndex)
        }
    }
   
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
        let contentOffset = collectionView.contentOffset.x
        currentOffset = contentOffset
        
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
        }
    }
    
    /// boilerplate code
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool { return true }
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        return context
    }
    
//    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
//        return getTargetOffsetForScrollingThere(for: proposedContentOffset)
//    }
//
    /// convenience - get the target offset, then you must scroll there.
//    func getTargetOffsetForScrollingThere(for point: CGPoint) -> CGPoint {
//        let (targetOffset, focusedIndex) = getTargetOffsetAndIndex(for: point)
//        self.focusedCellIndex = focusedIndex
//        return targetOffset
//    }
    
}


