//
//  ListsCollectionFlowLayout.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/8/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

/// columned layout, used by both Lists and Photos
class ListsCollectionFlowLayout: UICollectionViewFlowLayout {
    /// attributes for the headers / supplementary views
    var sectionAttributes = [UICollectionViewLayoutAttributes]()
    
    /// attributes for cells
    var layoutAttributes = [UICollectionViewLayoutAttributes]()
    
    var getSections: (() -> [Section])?
    var getSizeForSectionWithWidth: ((Int, CGFloat) -> CGSize)?
    var getTopPadding: (() -> CGFloat)?
    
    /// get the frame of a list cell from available width
    /// 1. index
    /// 2. the available width
    var getSizeForIndexWithWidth: ((Int, CGFloat) -> CGSize)?
    
    override init() {
        super.init()
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
    
    var contentSize = CGSize.zero /// the scrollable content size of the collection view
    override var collectionViewContentSize: CGSize { return contentSize } /// pass scrollable content size back to the collection view
    
    func getAvailableWidth(bounds: CGFloat, insets: UIEdgeInsets) -> CGFloat {
        let availableWidth = bounds
            - ListsCollectionConstants.sidePadding * 2
            - insets.left
            - insets.right
        return availableWidth
    }

    /// get the number of columns and each column's width from available bounds + insets
    func getColumns(bounds: CGFloat, insets: UIEdgeInsets) -> (Int, CGFloat) {
        let availableWidth = getAvailableWidth(bounds: bounds, insets: insets)
        
        let numberOfColumns = max(1, Int(availableWidth / ListsCollectionConstants.minCellWidth))
        
        /// space between columns
        let columnSpacing = CGFloat(numberOfColumns - 1) * ListsCollectionConstants.cellSpacing
        let columnWidth = (availableWidth - columnSpacing) / CGFloat(numberOfColumns)
        
        return (numberOfColumns, columnWidth)
    }

    override func prepare() { /// configure the cells' frames
        super.prepare()
        
        guard let sections = getSections?() else { return }
        guard let collectionView = collectionView else { return }
        let topPadding = getTopPadding?() ?? .zero

        let availableWidth = getAvailableWidth(bounds: collectionView.bounds.width, insets: collectionView.safeAreaInsets)
        var sectionAttributes = [UICollectionViewLayoutAttributes]()
        
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        let (numberOfColumns, columnWidth) = getColumns(bounds: collectionView.bounds.width, insets: collectionView.safeAreaInsets)
        
        var columnOffsets = [CGSize]()
        for columnIndex in 0 ..< numberOfColumns {
            let initialXOffset = ListsCollectionConstants.sidePadding
            let additionalXOffset = CGFloat(columnIndex) * columnWidth
            var leftSpacing = CGFloat(0)
            
            /// add LEFT spacing if not first index
            if columnIndex != 0 {
                leftSpacing = CGFloat(columnIndex) * ListsCollectionConstants.cellSpacing
            }
            
            let offset = CGSize(width: initialXOffset + additionalXOffset + leftSpacing, height: topPadding)
            columnOffsets.append(offset)
        }
        
        for sectionIndex in sections.indices {
            /// top out all the columns
            let maxHeight = columnOffsets.max(by: { $0.height < $1.height })?.height ?? 0

            if let size = getSizeForSectionWithWidth?(sectionIndex, availableWidth) {
                let attributes = UICollectionViewLayoutAttributes(
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                    with: IndexPath(item: 0, section: sectionIndex)
                )
                let headerFrame = CGRect(
                    x: ListsCollectionConstants.sidePadding,
                    y: maxHeight,
                    width: availableWidth,
                    height: size.height
                )
                attributes.frame = headerFrame

                sectionAttributes.append(attributes)
                for index in columnOffsets.indices {
                    columnOffsets[index].height = maxHeight + headerFrame.height + ListsCollectionConstants.cellSpacing
                }
            }
            
            for index in sections[sectionIndex].items.indices {
                if let size = getSizeForIndexWithWidth?(index, columnWidth) {
                    /// sometimes there are no `columnOffsets` due to `availableWidth` being too small
                    if let shortestColumnIndex = columnOffsets.indices.min(by: { columnOffsets[$0].height < columnOffsets[$1].height }) {
                        let columnOffset = columnOffsets[shortestColumnIndex]
                        let cellFrame = CGRect(
                            x: columnOffset.width,
                            y: columnOffset.height,
                            width: columnWidth,
                            height: size.height
                        )
                
                        let indexPath = IndexPath(item: index, section: sectionIndex)
                        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                        attributes.frame = cellFrame
                        layoutAttributes.append(attributes)
                        columnOffsets[shortestColumnIndex].height += cellFrame.height + ListsCollectionConstants.cellSpacing
                    }
                }
            }
        }

        let tallestColumnOffset = columnOffsets.max(by: { $0.height < $1.height }) ?? .zero
        contentSize = CGSize(
            width: collectionView.bounds.width
                - collectionView.safeAreaInsets.left
                - collectionView.safeAreaInsets.right,
            height: tallestColumnOffset.height
        )
        self.sectionAttributes = sectionAttributes
        self.layoutAttributes = layoutAttributes
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return sectionAttributes[safe: indexPath.item]
    }

    /// pass attributes to the collection view flow layout
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributes[safe: indexPath.item]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = layoutAttributes + sectionAttributes
        return attributes.filter { rect.intersects($0.frame) }
    }
}
