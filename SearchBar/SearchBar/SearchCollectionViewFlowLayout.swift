//
//  SearchCollectionViewFlowLayout.swift
//  SearchBar
//
//  Created by Zheng on 10/14/21.
//

import UIKit



class SearchCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
    }
    
    var getCellWidth: (() -> CGFloat)?
    
    var preparedOnce: Bool = false
    
    var layoutAttributes = [UICollectionViewLayoutAttributes]() /// store the frame of each item
    var contentSize = CGSize.zero /// the scrollable content size of the collection view
    override var collectionViewContentSize: CGSize { return contentSize } /// pass scrollable content size back to the collection view
    
    /// pass attributes to the collection view flow layout
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributes[indexPath.item]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        /// edge cells don't shrink, but the animation is perfect
         return layoutAttributes.filter { rect.intersects($0.frame) } /// try deleting this line
        
        /// edge cells shrink (yay!), but the animation glitches out
//        return shrinkingEdgeCellAttributes(in: rect)
    }
    
    /// makes the edge cells slowly shrink as you scroll
//    func shrinkingEdgeCellAttributes(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//        guard let collectionView = collectionView else { return nil }
//
//        var rectAttributes: [UICollectionViewLayoutAttributes] = []
//        /// rect of the visible collection view cells
//        let ogVisibleRect: CGRect = CGRect(origin: collectionView.contentOffset, size: collectionView.frame.size)
//        var visibleRect: CGRect
//
//
//        visibleRect = ogVisibleRect
//        rectAttributes = layoutAttributes.filter { rect.intersects($0.frame) }
//
//
//        let leadingCutoff: CGFloat = 10 /// once a cell reaches here, start shrinking it
//        let trailingCutoff: CGFloat
//        let paddingInsets: UIEdgeInsets /// apply shrinking even when cell has passed the screen's bounds
//
//
//        trailingCutoff = CGFloat(collectionView.bounds.width - leadingCutoff)
//        paddingInsets = UIEdgeInsets(top: 0, left: -50, bottom: 0, right: -50)
//
//
//        // Reset transform
//        for attributes in rectAttributes {
//            attributes.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
//            attributes.alpha = 0
//            attributes.zIndex = 0
//        }
//
//        var currentTopCount = 0
//        for attributes in rectAttributes where visibleRect.inset(by: paddingInsets).contains(attributes.center) {
//            /// center of each cell, converted to a point inside `visibleRect`
//
//            let center = attributes.center.x - visibleRect.origin.x
//
//            var offset: CGFloat?
//            var translation = CGPoint.zero
//            if center <= leadingCutoff {
//                offset = leadingCutoff - center /// distance from the cutoff, 0 if exactly on cutoff
//                translation.x  = pow((offset! / leadingCutoff), 1.5) * leadingCutoff
//            } else if center >= trailingCutoff {
//                offset = center - trailingCutoff
//                translation.x  = -pow((offset! / leadingCutoff), 1.5) * leadingCutoff
//            }
//
//            if let offset = offset {
//                let alpha = 1 - (pow(offset, 1.1) / 100)
//                let scale = 1 - (pow(offset, 1.1) / 5000) /// gradually shrink the cell
//
//                attributes.alpha = alpha
//                attributes.zIndex = Int(alpha * 100) /// if alpha is 1, keep on the top
//                attributes.transform = CGAffineTransform(scaleX: scale, y: scale).translatedBy(x: translation.x, y: translation.y)
//
//            } else {
//                currentTopCount += 1
//                attributes.alpha = 1
//                attributes.zIndex = 100 + currentTopCount /// maintain order even when on top
//            }
//        }
//        return rectAttributes
//    }
    
    /// make the layout (strip vs list) here
    override func prepare() { /// configure the cells' frames
        super.prepare()
        
        
        guard let collectionView = collectionView else { return }
        
        // FIX redundant prepare calls
        guard !preparedOnce else { return }
        preparedOnce = true
        layoutAttributes = []
        
        var contentSize = CGSize.zero
        var offset: CGPoint = .zero /// origin for each cell
        
        
        for itemIndex in 0..<collectionView.numberOfItems(inSection: 0) {
            let cellSize = CGSize(width: getCellWidth?() ?? 300, height: 48)
            contentSize.height = cellSize.height
            
            let indexPath = IndexPath(item: itemIndex, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            attributes.frame = CGRect(origin: offset, size: cellSize)
            layoutAttributes.append(attributes)
            
            let addedOffset = cellSize.width
            offset.x += addedOffset
        }
        
        
        contentSize.width += offset.x
        contentSize.height += offset.y
        self.contentSize = contentSize
    }
    
    /// boilerplate code
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool { return true }
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        return context
    }
    
    
    func reset(){
        preparedOnce = false
    }
    
}
