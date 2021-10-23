//
//  SearchCollectionViewFlowLayout.swift
//  SearchBar
//
//  Created by Zheng on 10/14/21.
//

import UIKit

//struct FieldCellLayout {
//    var origin = CGFloat(0)
//    var width = CGFloat(0)
//    var fullOrigin = CGFloat(0) /// origin when expanded
//    var fullWidth = CGFloat(0) /// width when expanded
//    var percentageShrunk = CGFloat(0) /// how much percent shrunk
//}
struct FieldOffset {
    var fullWidth = CGFloat(0)
    var shift = CGFloat(0) /// already multiplied by percentage
    var percentage = CGFloat(0)
}

class SearchCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
    }
    
    /// get data
    var getFields: (() -> [Field])?
    var getFullCellWidth: ((Int) -> CGFloat)?
    
    /// store the frame of each item
    /// plus other properties
    var layoutAttributes = [FieldLayoutAttributes]()
    
    /// collection view is about to reach the end (auto-scrolling) or has reached the end
    var reachedEndBeforeAddWordField = false
    
    /// call this from the scroll view delegate when
    /// 1. finger is down
    /// 2. `reachedEnd` is true
    var shouldUseOffsetWithAddNew = false

    /// actual content offset used by `prepare`
    var currentOffset = CGFloat(0)
    
    /// showing (past the point where it will auto-scroll) the last field or not
    var showingAddWordField = false
   
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
        return getTargetOffset(for: proposedContentOffset)
    }
    
    
    /// make the layout (strip vs list) here
    override func prepare() { /// configure the cells' frames
        super.prepare()
        
        
        
        guard let collectionView = collectionView else { return }
        let contentOffset = collectionView.contentOffset.x
        currentOffset = contentOffset
        
        
        guard let fields = getFields?() else { return }
        let fieldHuggingWidths = fields.map { $0.fieldHuggingWidth } /// array of each field's minimum size
        
        // MARK: Calculate shifting for each cell
        var cellOrigin = Constants.sidePadding /// origin for each cell
        
        var leftFieldOffsets = [FieldOffset]() /// array of each cell's shifting offset + percentage complete
        var rightFieldOffsets = [FieldOffset]() /// same, for fields after the focused one

        for index in fieldHuggingWidths.indices {
            let fullCellWidth = getFullCellWidth?(index) ?? 0
            
            var sidePadding = CGFloat(0)
            let cellOriginWithoutSidePadding: CGFloat
            if index == 0 {
                
                /// next cell is `fullCellWidth` + **cellSpacing** points away
                /// but subtract the left side gap (`sidePeekPadding` minus the side padding), which the content offset already travelled through
                sidePadding = Constants.cellSpacing - (Constants.sidePeekPadding - Constants.sidePadding)
                cellOriginWithoutSidePadding = cellOrigin - Constants.sidePadding
            } else if index == fieldHuggingWidths.count - 2 {
                sidePadding = Constants.cellSpacing - (Constants.sidePeekPadding - Constants.sidePadding)
                cellOriginWithoutSidePadding = cellOrigin - Constants.sidePeekPadding
                
            } else if index == fieldHuggingWidths.indices.last { /// add new field cell
                sidePadding = Constants.cellSpacing - (Constants.sidePeekPadding - Constants.sidePadding)
                cellOriginWithoutSidePadding = cellOrigin - Constants.sidePeekPadding
            } else {
                
                /// next cell is `fullCellWidth` + **cellSpacing** points away
                sidePadding = Constants.cellSpacing
                cellOriginWithoutSidePadding = cellOrigin - Constants.sidePeekPadding
            }
            
            if cellOriginWithoutSidePadding >= contentOffset { /// cell is not yet approached

                let distanceToNextCell = fullCellWidth + sidePadding
                
                let contentOffsetPlusWidth = contentOffset + distanceToNextCell /// is the field's origin (once the field is on the right, waiting)
                let distanceTravelledLeft = max(0, contentOffsetPlusWidth - cellOriginWithoutSidePadding) /// prevent negatives - when the field is way on the right and not yet waiting
                let percentage = 1 - (distanceTravelledLeft / distanceToNextCell) /// 0 when all the way left, 1 when right
                
                /// how much difference between the full width and the normal width, won't change.
                let differenceBetweenWidthAndFullWidth = fullCellWidth - fieldHuggingWidths[index]
                let shift = percentage * differenceBetweenWidthAndFullWidth
                let fieldOffset = FieldOffset(fullWidth: fullCellWidth, shift: shift, percentage:  percentage)
                rightFieldOffsets.append(fieldOffset)
                
            } else {
                
                /// how much to drag collection view, until the next field's origin reaches this field's origin
                /// add `sidePadding` to account for cell spacing
                let distanceToNextCell = fullCellWidth + sidePadding

                /// progress of content offset (positive) through the field, until it reaches the next field (`distanceToNextCell`)
                /// `min` = prevent progress from getting larger than `distanceToNextCell` (end of the cell)
                let distanceTravelledRight = min(distanceToNextCell, contentOffset - cellOriginWithoutSidePadding)
                let percentage = distanceTravelledRight / distanceToNextCell /// fraction

                /// how much difference between the full width and the normal width, won't change.
                let differenceBetweenWidthAndFullWidth = fullCellWidth - fieldHuggingWidths[index]
                let shift = percentage * differenceBetweenWidthAndFullWidth
                let fieldOffset = FieldOffset(fullWidth: fullCellWidth, shift: shift, percentage: percentage)
                leftFieldOffsets.append(fieldOffset)
                
            }
            
            var additionalOffset = fullCellWidth
            if index != fieldHuggingWidths.indices.last { additionalOffset += Constants.cellSpacing } /// don't add spacing for last cell
            cellOrigin += additionalOffset
        }
        
        // MARK: Apply ALL shifting to the start of the collection view
        var fullOrigin = Constants.sidePadding /// origin for each cell, in expanded mode
        var fullOriginWithoutAddNew = Constants.sidePadding
        var layoutAttributes = [FieldLayoutAttributes]() /// each cell's positioning attributes + additional custom properties
        
        func createLayoutAttribute(for fullIndex: Int, offsetIndex: Int, offsetArray: [FieldOffset], fullOrigin: inout CGFloat, leftSide: Bool) {
            
            let fieldOffset = offsetArray[offsetIndex]
            
            let origin: CGFloat
            let width: CGFloat
            
            if leftSide {
                let totalShiftingOffset = offsetArray.dropFirst(offsetIndex).reduce(0, { $0 + $1.shift })
                origin = fullOrigin + totalShiftingOffset
                width = fieldOffset.fullWidth - fieldOffset.shift
            } else {
                /// prefix current index directly, so **only add shift of previous fields** - don't add this current fields shift
                let totalShiftingOffset = offsetArray.prefix(offsetIndex).reduce(0, { $0 + $1.shift })
                let offset = (offsetIndex == 0) ? 0 : totalShiftingOffset
                origin = fullOrigin - offset
                width = fieldOffset.fullWidth - fieldOffset.shift
            }
            
            let indexPath = IndexPath(item: fullIndex, section: 0)
            let attributes = FieldLayoutAttributes(forCellWith: indexPath)
            attributes.frame = CGRect(x: origin, y: 0, width: width, height: Constants.cellHeight)
            attributes.fullOrigin = fullOrigin
            attributes.fullWidth = fieldOffset.fullWidth
            attributes.percentage = fieldOffset.percentage
            layoutAttributes.append(attributes)
            
            var additionalOffset = fieldOffset.fullWidth
            if fullIndex != fieldHuggingWidths.indices.last { additionalOffset += Constants.cellSpacing }
            fullOrigin += additionalOffset
            
            if fullIndex != fieldHuggingWidths.indices.last {
                var additionalOffset = fieldOffset.fullWidth
                if fullIndex != fieldHuggingWidths.count - 2 { additionalOffset += Constants.cellSpacing } /// don't add cell spacing for last non-AddNew field
                fullOriginWithoutAddNew += additionalOffset
            }
        }
        
        var currentCellIndex = 0
        for offsetIndex in leftFieldOffsets.indices {
            createLayoutAttribute(for: currentCellIndex, offsetIndex: offsetIndex, offsetArray: leftFieldOffsets, fullOrigin: &fullOrigin, leftSide: true)
            currentCellIndex += 1
        }

        for offsetIndex in rightFieldOffsets.indices {
            createLayoutAttribute(for: currentCellIndex, offsetIndex: offsetIndex, offsetArray: rightFieldOffsets, fullOrigin: &fullOrigin, leftSide: false)
            currentCellIndex += 1
        }
        
        /// set from scrollview delegate
        if shouldUseOffsetWithAddNew {
            self.contentSize = CGSize(width: fullOrigin + Constants.sidePadding, height: Constants.cellHeight)
        } else {
            self.contentSize = CGSize(width: fullOriginWithoutAddNew + Constants.sidePadding, height: Constants.cellHeight)
        }
        
        self.layoutAttributes = layoutAttributes
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
        
        /// handle end, but not actually swiped
        
        if
            showingAddWordField,
            let addWordFieldOrigin = layoutAttributes.last?.fullOrigin
        {
            reachedEndBeforeAddWordField = true
            let targetContentOffset = addWordFieldOrigin - Constants.sidePeekPadding
            return CGPoint(x: targetContentOffset, y: 0)
        } else {
            
            let centeredProposedContentOffset = point.x + ((collectionView?.bounds.width ?? 0) / 2) /// center to the screen
            
            /// find closest origin (by comparing middle of screen)
            /// use `full` since it was calculated already - it's the ideal origin and width
            /// dropLast to prevent focusing on `addNew` field
            let closestOrigin = layoutAttributes.dropLast().enumerated().min(by: {
                let firstCenter = $0.element.fullOrigin + ($0.element.fullWidth / 2)
                let secondCenter = $1.element.fullOrigin + ($1.element.fullWidth / 2)
                return abs(firstCenter - centeredProposedContentOffset) < abs(secondCenter - centeredProposedContentOffset)
            })!
            
            var targetContentOffset = closestOrigin.element.fullOrigin
            
            if closestOrigin.offset == 0 { /// index 0
                targetContentOffset -= Constants.sidePadding /// if left edge, account for side padding
            } else {
                targetContentOffset -= Constants.sidePeekPadding /// if inner cell, ignore side padding, instead account for peek padding
            }
            
            if closestOrigin.offset == layoutAttributes.count - 2 { /// last field before "add new" field
                reachedEndBeforeAddWordField = true
            } else {
                reachedEndBeforeAddWordField = false
            }
            
            return CGPoint(x: targetContentOffset, y: 0)
        }
    }
}


