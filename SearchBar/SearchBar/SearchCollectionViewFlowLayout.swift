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
    
    var getFields: (() -> [Field])?
    var getFullCellWidth: ((Int) -> CGFloat)?
    
    /// store the frame of each item
    /// plus other properties
    var layoutAttributes = [FieldLayoutAttributes]()
    
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
        
        layoutAttributes = []
        
        var contentSize = CGSize.zero
        
        
        guard let fields = getFields?() else { return }

        let widths = fields.map { $0.valueFrameWidth }
        
        let contentOffset = collectionView.contentOffset.x
//        + Constants.sidePadding
        
        // MARK: Calculate shifting for each cell
        var cellOrigin = Constants.sidePadding /// origin for each cell
        
        var leftFieldOffsets = [FieldOffset]() /// array of each cell's shifting offset + percentage complete
        var rightFieldOffsets = [FieldOffset]() /// same, for fields after the focused one
        
        
        for index in widths.indices {
            let fullCellWidth = getFullCellWidth?(index) ?? 0
            
            
//            let sidePadding = Constants.sidePeekPadding - (Constants.sidePadding + Constants.cellSpacing)
//            let sideOffset = Constants.sidePeekPadding - Constants.sidePadding
//            if index == 2 {
//                print("Content Offset: \(contentOffset), cell's origin: \(cellOrigin), sideOffset: \(sideOffset)")
//            }
            
//            let adjustedDifference =  Constants.sidePeekPadding - Constants.sidePadding
            
            var sidePadding = CGFloat(0)
            let cellOriginWithoutSidePadding: CGFloat
            if index == 0 {
                
                /// next cell is `fullCellWidth` + **cellSpacing** points away
                /// but subtract the left side gap (`sidePeekPadding` minus the side padding), which the content offset already travelled through
                sidePadding = Constants.cellSpacing - (Constants.sidePeekPadding - Constants.sidePadding)
                cellOriginWithoutSidePadding = cellOrigin - Constants.sidePadding
            } else {
                
                /// next cell is `fullCellWidth` + **cellSpacing** points away
                sidePadding = Constants.cellSpacing
                cellOriginWithoutSidePadding = cellOrigin - Constants.sidePeekPadding
            }
            
            if cellOriginWithoutSidePadding >= contentOffset { /// cell is not yet approached
//                rightFieldOffsets.append(FieldOffset(fullWidth: fullCellWidth, shift: 0, percentage: 0))

                let distanceToNextCell = fullCellWidth + sidePadding
                
                
                let contentOffsetPlusWidth = contentOffset + distanceToNextCell
                let distanceUntilApproached = min(distanceToNextCell, contentOffsetPlusWidth - cellOriginWithoutSidePadding)
                let percentage = 1 - distanceUntilApproached / distanceToNextCell /// fraction
                

                let differenceBetweenWidthAndFullWidth = min(0, fullCellWidth - widths[index])
                
                if index == 1 {
                    print("cOff: \(contentOffsetPlusWidth), origin \(cellOriginWithoutSidePadding)... \(contentOffsetPlusWidth - cellOriginWithoutSidePadding))")
                    print("Percentage: \(percentage), Full: \(fullCellWidth), norma: \(widths[index])")
//                    print("Distance: \(distanceUntilApproached), origin: \(cellOriginWithoutSidePadding), cOff: \(contentOffset), diff: \(differenceBetweenWidthAndFullWidth)")
                }

                let fieldOffset = FieldOffset(fullWidth: fullCellWidth, shift: percentage * differenceBetweenWidthAndFullWidth, percentage: percentage)
                rightFieldOffsets.append(fieldOffset)
            } else {
//                fieldOffsets.append(FieldOffset(fullWidth: fullCellWidth, shift: 0, percentage: 0))
                
                /// how much to drag collection view, until the next field's origin reaches this field's origin
                /// add `sidePadding` to account for cell spacing
                let distanceToNextCell = fullCellWidth + sidePadding

                /// progress of content offset (positive) through the field, until it reaches the next field (`distanceToNextCell`)
                /// `min` = prevent progress from getting larger than `distanceToNextCell` (end of the cell)
                let differenceBetweenContentOffsetAndCell = min(distanceToNextCell, contentOffset - cellOriginWithoutSidePadding)
                let percentage = differenceBetweenContentOffsetAndCell / distanceToNextCell /// fraction


                /// how much difference between the full width and the normal width, won't change.
                let differenceBetweenWidthAndFullWidth = max(0, fullCellWidth - widths[index])

                let fieldOffset = FieldOffset(fullWidth: fullCellWidth, shift: percentage * differenceBetweenWidthAndFullWidth, percentage: percentage)
                leftFieldOffsets.append(fieldOffset)
            }
            
            var additionalOffset = fullCellWidth
            if index != widths.indices.last { additionalOffset += Constants.cellSpacing }
            cellOrigin += additionalOffset
        }
        
        
        // MARK: Apply ALL shifting to the start of the collection view
        var fullOrigin = Constants.sidePadding /// origin for each cell, in expanded mode
        var layoutAttributes = [FieldLayoutAttributes]() /// each cell's positioning attributes + additional custom properties
        
        let leftOffsetsDebug = leftFieldOffsets.map { "w: \($0.fullWidth.int), s: \($0.shift.int), %: \($0.percentage)" }
        let rightOffsetsDebug = rightFieldOffsets.map { "w: \($0.fullWidth.int), s: \($0.shift.int), %: \($0.percentage)" }
//        print("\(leftOffsetsDebug)\n\(rightOffsetsDebug)\n\n")
    
        func createLayoutAttribute(for fullIndex: Int, offsetIndex: Int, offsetArray: [FieldOffset], fullOrigin: inout CGFloat) {
            
            let totalShiftingOffset = offsetArray.dropFirst(offsetIndex).reduce(0, { $0 + $1.shift })
//            print("\(offsetIndex): totalShiftingOffset: \(totalShiftingOffset)")
            let fieldOffset = offsetArray[offsetIndex]
            
            let origin = fullOrigin + totalShiftingOffset
            let width = fieldOffset.fullWidth - fieldOffset.shift
            
            let indexPath = IndexPath(item: fullIndex, section: 0)
            let attributes = FieldLayoutAttributes(forCellWith: indexPath)
            attributes.frame = CGRect(x: origin, y: 0, width: width, height: Constants.cellHeight)
            attributes.fullOrigin = fullOrigin
            attributes.fullWidth = fieldOffset.fullWidth
            attributes.percentage = fieldOffset.percentage
            layoutAttributes.append(attributes)
            
            var additionalOffset = fieldOffset.fullWidth
            if fullIndex != widths.indices.last { additionalOffset += Constants.cellSpacing } // fix
            fullOrigin += additionalOffset
        }
        func createRightLayoutAttribute(for fullIndex: Int, offsetIndex: Int, offsetArray: [FieldOffset], fullOrigin: inout CGFloat) {
            
//            let totalShiftingOffset = offsetArray.dropFirst(offsetIndex).reduce(0, { $0 + $1.shift })
//            print("\(offsetIndex): totalShiftingOffset: \(totalShiftingOffset)")
            let fieldOffset = offsetArray[offsetIndex]
            
            let origin = fullOrigin
//            + totalShiftingOffset
            let width = fieldOffset.fullWidth - fieldOffset.shift
            
            let indexPath = IndexPath(item: fullIndex, section: 0)
            let attributes = FieldLayoutAttributes(forCellWith: indexPath)
            attributes.frame = CGRect(x: origin, y: 0, width: width, height: Constants.cellHeight)
            attributes.fullOrigin = fullOrigin
            attributes.fullWidth = fieldOffset.fullWidth
            attributes.percentage = fieldOffset.percentage
            layoutAttributes.append(attributes)
            
            var additionalOffset = fieldOffset.fullWidth
            if fullIndex != widths.indices.last { additionalOffset += Constants.cellSpacing } // fix
            fullOrigin += additionalOffset
        }
        
//        let combinedArray = leftFieldOffsets + rightFieldOffsets
//        for index in combinedArray.indices {
//            createLayoutAttribute(for: index, offsetArray: combinedArray, fullOrigin: &fullOrigin)
//        }
        var currentCellIndex = 0
        for offsetIndex in leftFieldOffsets.indices {
            createLayoutAttribute(for: currentCellIndex, offsetIndex: offsetIndex, offsetArray: leftFieldOffsets, fullOrigin: &fullOrigin)
            currentCellIndex += 1
        }

        for offsetIndex in rightFieldOffsets.indices {
            createRightLayoutAttribute(for: currentCellIndex, offsetIndex: offsetIndex, offsetArray: rightFieldOffsets, fullOrigin: &fullOrigin)
            
            
            currentCellIndex += 1
        }
        
        contentSize.width = fullOrigin + Constants.sidePadding
        contentSize.height = Constants.cellHeight
        
        self.contentSize = contentSize
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
        let centeredProposedContentOffset = point.x + ((collectionView?.bounds.width ?? 0) / 2) /// center to the screen
        
        /// find closest origin (by comparing middle of screen)
        /// use `full` since it was calculated already - it's the ideal origin and width
        let closestOrigin = layoutAttributes.enumerated().min(by: {
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
        
//        print("---Going to \(targetContentOffset)")
        return CGPoint(x: targetContentOffset, y: 0)
//        return .zero
    }
    
    
}

open class FieldLayoutAttributes: UICollectionViewLayoutAttributes {
    
    var fullOrigin = CGFloat(0) /// origin when expanded
    var fullWidth = CGFloat(0) /// width when expanded
    var percentage = CGFloat(0) /// percentage shrunk
    
    override open func copy(with zone: NSZone?) -> Any {
        let copy = super.copy(with: zone) as! FieldLayoutAttributes
        copy.fullOrigin = fullOrigin
        copy.fullWidth = fullWidth
        copy.percentage = percentage
        
        return copy
    }
    
    override open func isEqual(_ object: Any?) -> Bool {
        guard let attributes = object as? FieldLayoutAttributes else { return false }
        guard
            attributes.fullOrigin == fullOrigin,
            attributes.fullWidth == fullWidth,
            attributes.percentage == percentage
        else { return false }
    
        return super.isEqual(object)
    }
    
}
