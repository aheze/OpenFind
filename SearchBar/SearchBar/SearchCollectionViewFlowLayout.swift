//
//  SearchCollectionViewFlowLayout.swift
//  SearchBar
//
//  Created by Zheng on 10/14/21.
//

import UIKit

struct FieldCellLayout {
    var origin = CGFloat(0)
    var width = CGFloat(0)
}

class SearchCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
    }
    
    var getFields: (() -> [Field])?
    var getFullCellWidth: ((Int) -> CGFloat)?
    
    var origins = [CGFloat]()
    
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
        
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        print("Proposed: \(proposedContentOffset)")
        
//        let closestOrigin = origins.min( by: { abs($0 - proposedContentOffset.x) < abs($1 - proposedContentOffset.x) } )!
//print("Closest: \(closestOrigin)")
        if let fields = getFields?() {
            
            var cellLayouts = [FieldCellLayout]()
            
            var currentCellOrigin = Constants.sidePadding /// origin for each cell
            
            for index in fields.indices {
                let fullCellWidth = getFullCellWidth?(index) ?? 0
                
                print("Full cell width for \(index): \(fullCellWidth)")
                var additionalOffset = fullCellWidth
                if index != fields.indices.last { additionalOffset += Constants.cellSpacing }
                
                
                let cellLayout = FieldCellLayout(origin: currentCellOrigin, width: fullCellWidth)
                cellLayouts.append(cellLayout)
                currentCellOrigin += additionalOffset
            }
            
            
            let centeredProposedContentOffset = proposedContentOffset.x + ((collectionView?.bounds.width ?? 0) / 2)
            print("Proposed: \(proposedContentOffset.x), new: \(centeredProposedContentOffset)")
            
            let closestOrigin = cellLayouts.enumerated().min( by: {
                let firstCenter = $0.element.origin + ($0.element.width / 2)
                let secondCenter = $1.element.origin + ($1.element.width / 2)
                return abs(firstCenter - centeredProposedContentOffset) < abs(secondCenter - centeredProposedContentOffset)
                
            } )!
            print("Closest: \(closestOrigin)")
            
            var targetContentOffset = closestOrigin.element.origin
            
            if closestOrigin.offset == 0 || closestOrigin.offset == fields.count - 1 {
                targetContentOffset -= Constants.sidePadding
            } else {
                targetContentOffset -= Constants.sidePeekPadding
            }
            
            print("Target: \(targetContentOffset)")
            return CGPoint(x: targetContentOffset, y: 0)
        }
        
        return proposedContentOffset
    }
    
    
    /// make the layout (strip vs list) here
    override func prepare() { /// configure the cells' frames
        super.prepare()
        
        
        guard let collectionView = collectionView else { return }
        
        
        layoutAttributes = []
        
        var contentSize = CGSize.zero
        var cellOffset = Constants.sidePadding /// origin for each cell
        
        guard let fields = getFields?() else { return }

        let widths = fields.map { $0.valueFrameWidth }
        let contentOffset = collectionView.contentOffset.x + Constants.sidePadding
        
        
        
        /// array of each cell's shifting offset
        var shiftingOffsets = [CGFloat]()
        
        for index in widths.indices {
            let fullCellWidth = getFullCellWidth?(index) ?? 0
            
            if cellOffset > contentOffset { /// cell is not yet approached
                shiftingOffsets.append(0)
            } else {
                let differenceBetweenContentOffsetAndCell = min(fullCellWidth, contentOffset - cellOffset)
                let percentage = differenceBetweenContentOffsetAndCell / fullCellWidth
                let shiftingOffset = percentage * (max(0, fullCellWidth - widths[index]))
                shiftingOffsets.append(shiftingOffset)
            }
            
            var additionalOffset = fullCellWidth
            if index != widths.indices.last { additionalOffset += Constants.cellSpacing }
            cellOffset += additionalOffset
        }
        
//        print("offsets: \(shiftingOffsets)")
        
        
        var origins = [CGFloat]()
        cellOffset = Constants.sidePadding
        
        for index in shiftingOffsets.indices {
            let fullCellWidth = getFullCellWidth?(index) ?? 0
            
            let indexPath = IndexPath(item: index, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            let totalShiftingOffset = shiftingOffsets.dropFirst(index).reduce(0, +)
            let shiftingOffset = shiftingOffsets[index]
//            print("Cell \(index)'s width: \(fullCellWidth - shiftingOffset), shifting offset: \(totalShiftingOffset).. total: \(cellOffset + totalShiftingOffset)")
            
            let origin = cellOffset + totalShiftingOffset
            origins.append(origin)
            attributes.frame = CGRect(x: origin, y: 0, width: fullCellWidth - shiftingOffset, height: Constants.cellHeight)
            
            layoutAttributes.append(attributes)
            
            var additionalOffset = fullCellWidth
            if index != widths.indices.last { additionalOffset += Constants.cellSpacing }
            cellOffset += additionalOffset
        }
        
        contentSize.height = Constants.cellHeight
        contentSize.width = cellOffset + Constants.sidePadding
        
//        print("Content: \(contentSize)")
        self.contentSize = contentSize
        self.origins = origins
         
    }
    
    /// boilerplate code
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool { return true }
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        return context
    }
    
    
}
