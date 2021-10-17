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
    var fullOrigin = CGFloat(0) /// origin when expanded
    var fullWidth = CGFloat(0) /// width when expanded
}

class SearchCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
    }
    
    var getFields: (() -> [Field])?
    var getFullCellWidth: ((Int) -> CGFloat)?
    
    var cellLayouts = [FieldCellLayout]()
    
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
        return getTargetOffset(for: proposedContentOffset)
    }
    
    
    /// make the layout (strip vs list) here
    override func prepare() { /// configure the cells' frames
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        
        layoutAttributes = []
        
        var contentSize = CGSize.zero
        
        
        guard let fields = getFields?() else { return }

        let widths = fields.map { $0.valueFrameWidth }
        let contentOffset = collectionView.contentOffset.x + Constants.sidePadding
        
        // MARK: Calculate shifting for each cell
        var cellOrigin = Constants.sidePadding /// origin for each cell
        var shiftingOffsets = [CGFloat]() /// array of each cell's shifting offset
        for index in widths.indices {
            let fullCellWidth = getFullCellWidth?(index) ?? 0
            
            if cellOrigin > contentOffset { /// cell is not yet approached
                shiftingOffsets.append(0)
            } else {
                
                /// when the fields stop, the content offset **falls short** of the end of the field.
                /// so, must account for that my subtracting some padding
                let sidePadding = Constants.sidePeekPadding - (Constants.sidePadding + Constants.cellSpacing)
                let adjustedFullWidth = fullCellWidth - sidePadding
                
                /// progress of content offset (positive) through the field, until it hits the field's width (`adjustedFullWidth`)
                let differenceBetweenContentOffsetAndCell = min(adjustedFullWidth, contentOffset - cellOrigin)
                let percentage = differenceBetweenContentOffsetAndCell / adjustedFullWidth /// fraction
                
                /// how much difference between the full width and the normal width, won't change.
                let differenceBetweenWidthAndFullWidth = max(0, fullCellWidth - widths[index])
                
                let shiftingOffset = percentage * differenceBetweenWidthAndFullWidth
                shiftingOffsets.append(shiftingOffset)
            }
            
            var additionalOffset = fullCellWidth
            if index != widths.indices.last { additionalOffset += Constants.cellSpacing }
            cellOrigin += additionalOffset
        }
        
        
        // MARK: Apply ALL shifting to the start of the collection view
        var fullOrigin = Constants.sidePadding /// origin for each cell, in expanded mode
        var cellLayouts = [FieldCellLayout]() /// each cell's positioning
        for index in shiftingOffsets.indices {
            let fullCellWidth = getFullCellWidth?(index) ?? 0
            
            let indexPath = IndexPath(item: index, section: 0)
            
            let totalShiftingOffset = shiftingOffsets.dropFirst(index).reduce(0, +)
            let shiftingOffset = shiftingOffsets[index]
            
            let origin = fullOrigin + totalShiftingOffset
            let width = fullCellWidth - shiftingOffset
            let cellLayout = FieldCellLayout(origin: origin, width: width, fullOrigin: fullOrigin, fullWidth: fullCellWidth)
            cellLayouts.append(cellLayout)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = CGRect(x: origin, y: 0, width: width, height: Constants.cellHeight)
            layoutAttributes.append(attributes)
            
            var additionalOffset = fullCellWidth
            if index != widths.indices.last { additionalOffset += Constants.cellSpacing }
            fullOrigin += additionalOffset
        }
        
        contentSize.width = fullOrigin + Constants.sidePadding
        contentSize.height = Constants.cellHeight
        
        self.contentSize = contentSize
        self.cellLayouts = cellLayouts
    }
    
    /// boilerplate code
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool { return true }
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        return context
    }
    
    /// get nearest field, then scroll to it (with padding)
    func getTargetOffset(for point: CGPoint) -> CGPoint {
        let centeredProposedContentOffset = point.x + ((collectionView?.bounds.width ?? 0) / 2) /// center to the screen
        
        /// find closest origin (by comparing middle of screen)
        /// use `full` since it was calculated already - it's the ideal origin and width
        let closestOrigin = cellLayouts.enumerated().min(by: {
            let firstCenter = $0.element.fullOrigin + ($0.element.fullWidth / 2)
            let secondCenter = $1.element.fullOrigin + ($1.element.fullWidth / 2)
            return abs(firstCenter - centeredProposedContentOffset) < abs(secondCenter - centeredProposedContentOffset)
        })!
        
        var targetContentOffset = closestOrigin.element.fullOrigin
        
        if closestOrigin.offset == 0 {
            targetContentOffset -= Constants.sidePadding /// if left edge, account for side padding
        } else {
            targetContentOffset -= Constants.sidePeekPadding /// if inner cell, ignore side padding, instead account for peek padding
        }
        
        print("Target: \(targetContentOffset)")
        return CGPoint(x: targetContentOffset, y: 0)
    }
    
}
