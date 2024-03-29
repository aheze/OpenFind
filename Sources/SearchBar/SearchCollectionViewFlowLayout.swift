//
//  SearchCollectionViewFlowLayout.swift
//  SearchBar
//
//  Created by Zheng on 10/14/21.
//

import UIKit

class SearchCollectionViewFlowLayout: UICollectionViewFlowLayout {
    var searchViewModel: SearchViewModel
    var collectionViewModel: SearchCollectionViewModel
    
    init(
        searchViewModel: SearchViewModel,
        collectionViewModel: SearchCollectionViewModel
    ) {
        self.searchViewModel = searchViewModel
        self.collectionViewModel = collectionViewModel
        super.init()
    }

    /// store the frame of each item
    /// plus other properties
    var layoutAttributes = [FieldLayoutAttributes]()
    
    /// actual content offset used by `prepare`
    var currentOffset = CGFloat(0)

    var contentSize = CGSize.zero /// the scrollable content size of the collection view
    override var collectionViewContentSize: CGSize { return contentSize } /// pass scrollable content size back to the collection view
    
    /// pass attributes to the collection view flow layout
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributes[safe: indexPath.item]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return layoutAttributes.filter { rect.intersects($0.frame) }
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let (offset, focusedIndex) = getTargetOffsetAndIndex(for: proposedContentOffset, velocity: velocity)
        collectionViewModel.focusedCellIndex = focusedIndex
        return offset
    }
    
    /// called after rotation
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        if let focusedCellIndex = collectionViewModel.focusedCellIndex {
            let attributes = layoutAttributes[safe: focusedCellIndex]
            var targetContentOffset = attributes?.fullOrigin ?? proposedContentOffset.x
            if focusedCellIndex == 0 { /// index 0
                targetContentOffset -= sidePaddingLeft /// if left edge, account for side padding
            } else {
                targetContentOffset -= sidePeekPaddingLeft /// if inner cell, ignore side padding, instead account for peek padding
            }
            return CGPoint(x: targetContentOffset, y: 0)
        }
        return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
    }
    
    /// make the layout (strip vs list) here
    override func prepare() { /// configure the cells' frames
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        let contentOffset = collectionView.contentOffset.x
        
        currentOffset = contentOffset
        
        let fields = searchViewModel.fields
        var fieldHuggingWidths = fields.map { $0.fieldHuggingWidth } /// array of each field's minimum size

        if let deletedIndex = collectionViewModel.deletedIndex {
            fieldHuggingWidths[deletedIndex] = 0
        }
        
        // MARK: Calculate shifting for each cell

        var cellOrigin = sidePaddingLeft /// origin for each cell
        
        var leftFieldOffsets = [FieldOffset]() /// array of each cell's shifting offset + percentage complete
        var rightFieldOffsets = [FieldOffset]() /// same, for fields after the focused one
        
        for index in fieldHuggingWidths.indices {
            let fullCellWidth = collectionViewModel.getFullCellWidth?(index) ?? 0

            var adjustedSidePadding = CGFloat(0)
            var cellOriginWithoutSidePadding: CGFloat /// the cell's origin if there was no left padding (focused cell would have 0)
            
            if index == 0 {
                /// next cell is `fullCellWidth` + **cellSpacing** points away
                /// but subtract the left side gap (`sidePeekPadding` minus the side padding), which the content offset already travelled through
                adjustedSidePadding = searchViewModel.configuration.cellSpacing - (sidePeekPaddingLeft - sidePaddingLeft)
                cellOriginWithoutSidePadding = cellOrigin - sidePaddingLeft
            } else if index == fieldHuggingWidths.count - 2 {
                adjustedSidePadding = searchViewModel.configuration.cellSpacing - (sidePeekPaddingLeft - sidePaddingLeft)
                cellOriginWithoutSidePadding = cellOrigin - sidePeekPaddingLeft
            } else if index == fieldHuggingWidths.indices.last { /// add new field cell
                cellOriginWithoutSidePadding = cellOrigin - sidePeekPaddingLeft
            } else {
                /// next cell is `fullCellWidth` + **cellSpacing** points away
                adjustedSidePadding = searchViewModel.configuration.cellSpacing
                cellOriginWithoutSidePadding = cellOrigin - sidePeekPaddingLeft
            }

            if cellOriginWithoutSidePadding >= contentOffset { /// cell is not yet approached
                let distanceToNextCell = fullCellWidth + adjustedSidePadding
                
                let contentOffsetPlusWidth = contentOffset + distanceToNextCell /// is the field's origin (once the field is on the right, waiting)
                let distanceTravelledLeft = max(0, contentOffsetPlusWidth - cellOriginWithoutSidePadding) /// prevent negatives - when the field is way on the right and not yet waiting
                let percentage = 1 - (distanceTravelledLeft / distanceToNextCell) /// 0 when all the way left, 1 when right
                
                /// how much difference between the full width and the normal width, won't change.
                let differenceBetweenWidthAndFullWidth = fullCellWidth - fieldHuggingWidths[index]
                let shift = percentage * differenceBetweenWidthAndFullWidth
                
                var alpha = CGFloat(1)
                if index == fieldHuggingWidths.count - 1 {
                    /// only highlight/unhighlight when cell is not being instantly added
                    if !collectionViewModel.currentConvertingAddNewCellToRegularCell {
                        /// when hit the edge already
                        if collectionViewModel.shouldUseOffsetWithAddNew {
                            let percentage = distanceTravelledLeft / (searchViewModel.configuration.addWordFieldSnappingFactor * distanceToNextCell)
                            alpha = min(1, percentage)
                            
                            /// highlight/tap `true` if percentage > 1
                            let shouldHighlight = percentage > 1
                            if shouldHighlight {
                                if !collectionViewModel.highlightingAddWordField { /// don't call too many times
                                    collectionViewModel.highlightingAddWordField = true
                                    collectionViewModel.highlightAddNewField?(true)
                                }
                            } else {
                                if collectionViewModel.highlightingAddWordField { /// don't call too many times
                                    collectionViewModel.highlightingAddWordField = false
                                    collectionViewModel.highlightAddNewField?(false)
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
                let distanceToNextCell = fullCellWidth + adjustedSidePadding
                
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
            if index != fieldHuggingWidths.indices.last { additionalOffset += searchViewModel.configuration.cellSpacing } /// don't add spacing for last cell
            cellOrigin += additionalOffset
        }
        
        // MARK: Apply ALL shifting to the start of the collection view

        var fullOrigin = sidePaddingLeft /// origin for each cell, in expanded mode
        var fullOriginWithoutAddNew = sidePaddingLeft
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
            attributes.frame = CGRect(
                x: origin,
                y: searchViewModel.isLandscape ? searchViewModel.configuration.barTopPaddingLandscape : searchViewModel.configuration.barTopPadding,
                width: width,
                height: searchViewModel.getCellHeight()
            )
            attributes.alpha = fieldOffset.alpha
            attributes.percentage = fieldOffset.percentage
            attributes.configuration = searchViewModel.configuration /// save the configuration first
            
            if let deletedIndex = collectionViewModel.deletedIndex, deletedIndex == fullIndex {
                attributes.transform = .init(scaleX: 0.5, y: 0.5)
                attributes.alpha = 0
                
                /// make left and right constraints 0 to prevent conflicts
                attributes.beingDeleted = true
            }
            
            attributes.fullOrigin = fullOrigin
            attributes.fullWidth = fieldOffset.fullWidth
            layoutAttributes.append(attributes)
            
            var additionalOffset = fieldOffset.fullWidth
            if fullIndex != fieldHuggingWidths.indices.last { additionalOffset += searchViewModel.configuration.cellSpacing }
            fullOrigin += additionalOffset
            
            if fullIndex != fieldHuggingWidths.indices.last {
                var additionalOffset = fieldOffset.fullWidth
                if fullIndex != fieldHuggingWidths.count - 2 { additionalOffset += searchViewModel.configuration.cellSpacing } /// don't add cell spacing for last non-AddNew field
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
        if collectionViewModel.shouldUseOffsetWithAddNew {
            contentSize = CGSize(
                width: fullOrigin + sidePaddingRight,
                height: searchViewModel.getCellHeight() +
                    (searchViewModel.isLandscape ? searchViewModel.configuration.barBottomPaddingLandscape : searchViewModel.configuration.barBottomPadding)
            )
        } else {
            contentSize = CGSize(
                width: fullOriginWithoutAddNew + sidePaddingRight,
                height: searchViewModel.getCellHeight() +
                    (searchViewModel.isLandscape ? searchViewModel.configuration.barBottomPaddingLandscape : searchViewModel.configuration.barBottomPadding)
            )
        }
        
        sectionInset = .zero
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0

        self.layoutAttributes = layoutAttributes
        
        if !collectionViewModel.preparedOnce {
            collectionViewModel.preparedOnce = true
            
            /// get the target offset for the first cell
            let targetOffset = getPointForCell(at: 0)
            collectionViewModel.focusedCellIndex = 0
            collectionView.contentOffset.x = targetOffset.x
            currentOffset = targetOffset.x
        }
    }
    
    var safeAreaInsets: UIEdgeInsets {
        collectionView?.safeAreaInsets ?? .zero
    }
    var sidePeekPaddingLeft: CGFloat {
        return searchViewModel.configuration.sidePeekPadding + safeAreaInsets.left
    }
    
    var sidePeekPaddingRight: CGFloat {
        return searchViewModel.configuration.sidePeekPadding + safeAreaInsets.right
    }
    
    var sidePaddingLeft: CGFloat {
        return searchViewModel.configuration.sidePadding + safeAreaInsets.left
    }
    
    var sidePaddingRight: CGFloat {
        return searchViewModel.configuration.sidePadding + safeAreaInsets.right
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
    
    /// make sure to set the `focused cell` index later.
    func getPointForCell(at index: Int) -> CGPoint {
        guard let attributes = layoutAttributes[safe: index] else { return .zero }
        var offset = attributes.fullOrigin
        if index == 0 { /// index 0
            offset -= sidePaddingLeft /// if left edge, account for side padding
        } else {
            offset -= sidePeekPaddingLeft /// if inner cell, ignore side padding, instead account for peek padding
        }
        
        if index == layoutAttributes.count - 2 { /// last field before "add new" field
            collectionViewModel.reachedEndBeforeAddWordField = true
        } else {
            collectionViewModel.reachedEndBeforeAddWordField = false
        }
        
        return CGPoint(x: offset, y: 0)
    }
    
    /// get nearest field, then scroll to it (with padding)
    func getTargetOffsetAndIndex(for point: CGPoint, velocity: CGPoint) -> (CGPoint, Int?) {
        if /// handle end, but not actually swiped
            collectionViewModel.highlightingAddWordField,
            let addWordFieldOrigin = layoutAttributes.last?.fullOrigin
        {
            collectionViewModel.reachedEndBeforeAddWordField = true
            let targetContentOffset = addWordFieldOrigin - sidePeekPaddingRight
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
                collectionViewModel.currentConvertingAddNewCellToRegularCell = true
                collectionViewModel.convertAddNewCellToRegularCell?() { [weak self] in
                    self?.collectionViewModel.currentConvertingAddNewCellToRegularCell = false
                }
                
                if let lastOrigin = layoutAttributes[safe: layoutAttributes.count - 1]?.fullOrigin {
                    targetContentOffset = lastOrigin
                    closestAttributeIndex = layoutAttributes.count - 1 /// make sure the focus is changed
                }
            }
            
            if closestAttributeIndex == 0 { /// index 0
                targetContentOffset -= sidePaddingLeft /// if left edge, account for side padding
            } else {
                targetContentOffset -= sidePeekPaddingLeft /// if inner cell, ignore side padding, instead account for peek padding
            }
            
            if closestAttributeIndex == layoutAttributes.count - 2 { /// last field before "add new" field
                collectionViewModel.reachedEndBeforeAddWordField = true
            } else {
                collectionViewModel.reachedEndBeforeAddWordField = false
            }
            
            return (CGPoint(x: targetContentOffset, y: 0), closestAttributeIndex)
        }
    }
}
