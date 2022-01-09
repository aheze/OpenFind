//
//  SearchCollectionViewFlowLayout.swift
//  SearchBar
//
//  Created by Zheng on 10/14/21.
//

import UIKit

class SearchCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    var configuration: SearchConfiguration
    
    init(configuration: SearchConfiguration) {
        self.configuration = configuration
        super.init()
    }
    
    /// prepared before?
    var preparedOnce = false
    
    /// get data
    var getFields: (() -> [Field])?
    var getFullCellWidth: ((Int) -> CGFloat)?
    
    /// pass back data
    var highlightAddNewField: ((Bool) -> Void)?
    
    /// fast swipe, instantly convert
    var convertAddNewToRegularCellInstantly: ((@escaping () -> Void) -> Void)?
    var convertingInstantly = false /// if in progress of converting
    
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
    
    /// old / new
    var focusedCellIndexChanged: ((Int?, Int?) -> Void)?
    
    /// index of focused/expanded cell
    var focusedCellIndex: Int? {
        didSet {
            focusedCellIndexChanged?(oldValue, focusedCellIndex)
        }
    }
    
    var deletedIndex: Int?
    var fallbackIndex: Int?
    
    /// showing (past the point where it will auto-scroll) the last field or not
    var highlightingAddWordField = false
    
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
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let offset = getTargetOffsetForScrollingThere(for: proposedContentOffset, velocity: velocity)
        return offset
    }
    
    
    
    /// make the layout (strip vs list) here
    override func prepare() { /// configure the cells' frames
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        let contentOffset = collectionView.contentOffset.x
        currentOffset = contentOffset
        
        guard let fields = getFields?() else { return }
        var fieldHuggingWidths = fields.map { $0.fieldHuggingWidth } /// array of each field's minimum size

        if let deletedIndex = deletedIndex {
            fieldHuggingWidths[deletedIndex] = 0
        }
        
        // MARK: Calculate shifting for each cell

        var cellOrigin = configuration.sidePadding /// origin for each cell
        
        var leftFieldOffsets = [FieldOffset]() /// array of each cell's shifting offset + percentage complete
        var rightFieldOffsets = [FieldOffset]() /// same, for fields after the focused one
        
        for index in fieldHuggingWidths.indices {
            let fullCellWidth = getFullCellWidth?(index) ?? 0

            var sidePadding = CGFloat(0)
            var cellOriginWithoutSidePadding: CGFloat
            
            
            if index == 0 {
                /// next cell is `fullCellWidth` + **cellSpacing** points away
                /// but subtract the left side gap (`sidePeekPadding` minus the side padding), which the content offset already travelled through
                sidePadding = configuration.cellSpacing - (configuration.sidePeekPadding - configuration.sidePadding)
                cellOriginWithoutSidePadding = cellOrigin - configuration.sidePadding
            } else if index == fieldHuggingWidths.count - 2 {
                sidePadding = configuration.cellSpacing - (configuration.sidePeekPadding - configuration.sidePadding)
                cellOriginWithoutSidePadding = cellOrigin - configuration.sidePeekPadding
            } else if index == fieldHuggingWidths.indices.last { /// add new field cell
                cellOriginWithoutSidePadding = cellOrigin - configuration.sidePeekPadding
            } else {
                /// next cell is `fullCellWidth` + **cellSpacing** points away
                sidePadding = configuration.cellSpacing
                cellOriginWithoutSidePadding = cellOrigin - configuration.sidePeekPadding
            }

            if cellOriginWithoutSidePadding >= contentOffset { /// cell is not yet approached
                let distanceToNextCell = fullCellWidth + sidePadding
                
                let contentOffsetPlusWidth = contentOffset + distanceToNextCell /// is the field's origin (once the field is on the right, waiting)
                let distanceTravelledLeft = max(0, contentOffsetPlusWidth - cellOriginWithoutSidePadding) /// prevent negatives - when the field is way on the right and not yet waiting
                let percentage = 1 - (distanceTravelledLeft / distanceToNextCell) /// 0 when all the way left, 1 when right
                
                /// how much difference between the full width and the normal width, won't change.
                let differenceBetweenWidthAndFullWidth = fullCellWidth - fieldHuggingWidths[index]
                let shift = percentage * differenceBetweenWidthAndFullWidth
                
                var alpha = CGFloat(1)
                if index == fieldHuggingWidths.count - 1 {
                    /// only highlight/unhighlight when cell is not being instantly added
                    if !convertingInstantly {
                        /// when hit the edge already
                        if shouldUseOffsetWithAddNew {
                            let percentage = distanceTravelledLeft / (configuration.addWordFieldSnappingFactor * distanceToNextCell)
                            alpha = min(1, percentage)
                            
                            /// highlight/tap `true` if percentage > 1
                            let shouldHighlight = percentage > 1
                            if shouldHighlight {
                                if !highlightingAddWordField { /// don't call too many times
                                    highlightingAddWordField = true
                                    highlightAddNewField?(true)
                                }
                            } else {
                                if highlightingAddWordField { /// don't call too many times
                                    highlightingAddWordField = false
                                    highlightAddNewField?(false)
                                }
                            }
                        } else {
                            alpha = 0 /// still haven't hit edge, so hide always, even when bouncing
                        }
                    }
                }
                
                let fieldOffset = FieldOffset(fullWidth: fullCellWidth, percentage: percentage, shift: shift, alpha: alpha)
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
                let fieldOffset = FieldOffset(fullWidth: fullCellWidth, percentage: percentage, shift: shift)
                leftFieldOffsets.append(fieldOffset)
            }
            
            var additionalOffset = fullCellWidth
            if index != fieldHuggingWidths.indices.last { additionalOffset += configuration.cellSpacing } /// don't add spacing for last cell
            cellOrigin += additionalOffset
        }
        
        // MARK: Apply ALL shifting to the start of the collection view

        var fullOrigin = configuration.sidePadding /// origin for each cell, in expanded mode
        var fullOriginWithoutAddNew = configuration.sidePadding
        var layoutAttributes = [FieldLayoutAttributes]() /// each cell's positioning attributes + additional custom properties
        
        func createLayoutAttribute(for fullIndex: Int, offsetIndex: Int, offsetArray: [FieldOffset], fullOrigin: inout CGFloat, leftSide: Bool) {
            let fieldOffset = offsetArray[offsetIndex]
            
            var origin: CGFloat
            var width: CGFloat
            
            if leftSide {
                let totalShiftingOffset = offsetArray.dropFirst(offsetIndex).reduce(0) { $0 + $1.shift }
                origin = fullOrigin + totalShiftingOffset
                width = fieldOffset.fullWidth - fieldOffset.shift
            } else {
                /// prefix current index directly, so **only add shift of previous fields** - don't add this current fields shift
                let totalShiftingOffset = offsetArray.prefix(offsetIndex).reduce(0) { $0 + $1.shift }
                let offset = (offsetIndex == 0) ? 0 : totalShiftingOffset
                origin = fullOrigin - offset
                width = fieldOffset.fullWidth - fieldOffset.shift
            }
            
            
            
            let indexPath = IndexPath(item: fullIndex, section: 0)
            let attributes = FieldLayoutAttributes(forCellWith: indexPath)
            attributes.frame = CGRect(x: origin, y: 0, width: width, height: configuration.cellHeight)
            attributes.alpha = fieldOffset.alpha
            attributes.percentage = fieldOffset.percentage
            
            if let deletedIndex = deletedIndex, deletedIndex == fullIndex {
                attributes.transform = .init(scaleX: 0.5, y: 0.5)
                attributes.alpha = 0
                
                /// make left and right constraints 0 to prevent conflicts
                attributes.beingDeleted = true
            }
            
            attributes.fullOrigin = fullOrigin
            attributes.fullWidth = fieldOffset.fullWidth
            layoutAttributes.append(attributes)
            
            var additionalOffset = fieldOffset.fullWidth
            if fullIndex != fieldHuggingWidths.indices.last { additionalOffset += configuration.cellSpacing }
            fullOrigin += additionalOffset
            
            if fullIndex != fieldHuggingWidths.indices.last {
                var additionalOffset = fieldOffset.fullWidth
                if fullIndex != fieldHuggingWidths.count - 2 { additionalOffset += configuration.cellSpacing } /// don't add cell spacing for last non-AddNew field
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
            contentSize = CGSize(width: fullOrigin + configuration.sidePadding, height: configuration.cellHeight)
        } else {
            contentSize = CGSize(width: fullOriginWithoutAddNew + configuration.sidePadding, height: configuration.cellHeight)
        }
        
        self.layoutAttributes = layoutAttributes
        
        if !preparedOnce {
            preparedOnce = true
            
            /// get the target offset
            let targetOffset = getTargetOffsetForScrollingThere(for: CGPoint(x: contentOffset, y: 0), velocity: .zero)
            collectionView.contentOffset.x = targetOffset.x
            currentOffset = targetOffset.x
        }
    }
    
    /// boilerplate code
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool { return true }
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        return context
    }
    
    /// convenience - get the target offset, then you must scroll there.
    func getTargetOffsetForScrollingThere(for point: CGPoint, velocity: CGPoint) -> CGPoint {
        let (targetOffset, focusedIndex) = getTargetOffsetAndIndex(for: point, velocity: velocity)
        focusedCellIndex = focusedIndex
        return targetOffset
    }
    
    /// get nearest field, then scroll to it (with padding)
    func getTargetOffsetAndIndex(for point: CGPoint, velocity: CGPoint) -> (CGPoint, Int?) {
        if /// handle end, but not actually swiped
            highlightingAddWordField,
            let addWordFieldOrigin = layoutAttributes.last?.fullOrigin
        {
            reachedEndBeforeAddWordField = true
            let targetContentOffset = addWordFieldOrigin - configuration.sidePeekPadding
            return (CGPoint(x: targetContentOffset, y: 0), layoutAttributes.indices.last)
        } else {
            let centeredProposedContentOffset = point.x + ((collectionView?.bounds.width ?? 0) / 2) /// center to the screen
            let pickedAttributes: [FieldLayoutAttributes?]
            
            switch velocity.x {
            case _ where velocity.x < 0:
                pickedAttributes = layoutAttributes.map { layoutAttribute in
                    
                    /// must be `<=` to prevent glitching when swiping left fast on first field
                    let isCandidate = layoutAttribute.fullOrigin + (layoutAttribute.fullWidth / 2) <= centeredProposedContentOffset
                    return isCandidate ? layoutAttribute : nil
                }
            case _ where velocity.x > 0:
                pickedAttributes = layoutAttributes.map { layoutAttribute in
                    let isCandidate = layoutAttribute.fullOrigin + (layoutAttribute.fullWidth / 2) >= centeredProposedContentOffset
                    return isCandidate ? layoutAttribute : nil
                }
            default:
                pickedAttributes = layoutAttributes
            }
            
            /// find closest origin
            /// use `full` since it was calculated already - it's the ideal origin and width
            /// dropLast to prevent focusing on `addNew` field
            var (closestAttribute, closestAttributeIndex, closestDistance): (FieldLayoutAttributes?, Int, CGFloat) = (nil, 0, CGFloat.infinity)
            for (index, attribute) in pickedAttributes.dropLast().enumerated() {
                if let layoutAttribute = attribute {
                    let distance = abs(layoutAttribute.fullOrigin + (layoutAttribute.fullWidth / 2) - centeredProposedContentOffset)
                    if distance < closestDistance {
                        closestAttribute = layoutAttribute
                        closestAttributeIndex = index
                        closestDistance = distance
                    }
                }
            }
            
            var targetContentOffset = CGFloat(0)
            
            if let closestAttribute = closestAttribute {
                targetContentOffset = closestAttribute.fullOrigin
            } else { /// swiped to the last one. Instantly add it.
                convertingInstantly = true
                convertAddNewToRegularCellInstantly?() { [weak self] in
                    self?.convertingInstantly = false
                    //                    highlightAddNewField?(false)
                }
                
                if let lastOrigin = layoutAttributes[safe: layoutAttributes.count - 1]?.fullOrigin {
                    targetContentOffset = lastOrigin
                    closestAttributeIndex = layoutAttributes.count - 1 /// make sure the focus is changed
                }
            }
            
            if closestAttributeIndex == 0 { /// index 0
                targetContentOffset -= configuration.sidePadding /// if left edge, account for side padding
            } else {
                targetContentOffset -= configuration.sidePeekPadding /// if inner cell, ignore side padding, instead account for peek padding
            }
            
            if closestAttributeIndex == layoutAttributes.count - 2 { /// last field before "add new" field
                reachedEndBeforeAddWordField = true
            } else {
                reachedEndBeforeAddWordField = false
            }
            
            return (CGPoint(x: targetContentOffset, y: 0), closestAttributeIndex)
        }
    }
}
