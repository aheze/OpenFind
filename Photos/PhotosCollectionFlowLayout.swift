//
//  PhotosCollectionFlowLayout.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/14/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

enum PhotosCollectionType {
    case sections([Section])
    case photos([Photo])
}

enum PhotosAttributes {
    case sections([SectionLayout])
    case attributes([UICollectionViewLayoutAttributes]) /// photos only
    
    struct SectionLayout {
        var categorization: PhotosSectionCategorization?
        var headerLayoutAttributes = PhotosSectionHeaderLayoutAttributes()
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
    }
}

class PhotosSectionHeaderLayoutAttributes: UICollectionViewLayoutAttributes {
    /// the month ranges that are in this row (when multiple months in single row)
    var encompassingCategorizations = [PhotosSectionCategorization]()
    var originalYOffset = CGFloat(0) /// y origin, without sticky header stuff
    var isVisible = false /// hide if already another header with same content
    
    override func copy(with zone: NSZone?) -> Any {
        let copy = super.copy(with: zone) as! Self
        copy.encompassingCategorizations = encompassingCategorizations
        copy.originalYOffset = originalYOffset
        copy.isVisible = isVisible
        return copy
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let attributes = object as? Self else { return false }
        guard
            attributes.encompassingCategorizations == encompassingCategorizations,
            attributes.originalYOffset == originalYOffset,
            attributes.isVisible == isVisible
        else { return false }
        return super.isEqual(object)
    }
}

class PhotosCollectionFlowLayout: UICollectionViewFlowLayout {
    var getContent: (() -> PhotosCollectionType)?
    
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
    
    var photosAttributes = PhotosAttributes.attributes([])
    var contentSize = CGSize.zero /// the scrollable content size of the collection view
    var columnWidth = CGFloat(0) /// width of each column. Needed for bounds change calculations
    override var collectionViewContentSize: CGSize { return contentSize } /// pass scrollable content size back to the collection view
    
    func getShortestColumnIndex(from columnOffsets: [CGSize]) -> Int? {
        guard !columnOffsets.isEmpty else { return nil }
        var (smallestIndex, smallestHeight) = (0, CGFloat.infinity)
        for offsetIndex in columnOffsets.indices {
            let offset = columnOffsets[offsetIndex].height
            
            /// add a little padding to favor left alignment
            if offset + 0.5 < smallestHeight {
                smallestIndex = offsetIndex
                smallestHeight = offset
            }
        }
        return smallestIndex
    }

    func createLayoutAttributes(
        itemCount: Int,
        columnOffsets: inout [CGSize],
        inside sectionIndex: Int = 0
    ) -> [UICollectionViewLayoutAttributes] {
        // MARK: Create items

        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        for itemIndex in 0 ..< itemCount {
            /// sometimes there are no `columnOffsets` due to `availableWidth` being too small
            if let shortestColumnIndex = getShortestColumnIndex(from: columnOffsets) {
                let columnOffset = columnOffsets[shortestColumnIndex]
                let cellFrame = CGRect(
                    x: columnOffset.width,
                    y: columnOffset.height,
                    width: columnWidth,
                    height: columnWidth
                )
            
                let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: itemIndex, section: sectionIndex))
                attributes.frame = cellFrame
                layoutAttributes.append(attributes)
                columnOffsets[shortestColumnIndex].height += cellFrame.height + PhotosConstants.cellSpacing
            }
        }
        return layoutAttributes
    }

    override func prepare() { /// configure the cells' frames
        super.prepare()
        guard let collectionView = collectionView else { return }
        var photosAttributes = PhotosAttributes.attributes([])
        
        let availableWidth = collectionView.bounds.width
            - PhotosConstants.sidePadding * 2
            - collectionView.safeAreaInsets.left
            - collectionView.safeAreaInsets.right
        
        let (numberOfColumns, columnWidth) = PhotosConstants.minCellWidth.getColumns(availableWidth: availableWidth)
        self.columnWidth = columnWidth
        
        var columnOffsets = [CGSize]()
        for columnIndex in 0 ..< numberOfColumns {
            let initialXOffset = PhotosConstants.sidePadding
            let additionalXOffset = CGFloat(columnIndex) * columnWidth
            var leftSpacing = CGFloat(0)
            
            /// add LEFT spacing if not first index
            if columnIndex != 0 {
                leftSpacing = CGFloat(columnIndex) * PhotosConstants.cellSpacing
            }
            
            let offset = CGSize(width: initialXOffset + additionalXOffset + leftSpacing, height: 0)
            columnOffsets.append(offset)
        }
        
        guard let content = getContent?() else { return }
        switch content {
        case .sections(let sections):
            var sectionLayouts = [PhotosAttributes.SectionLayout]()
            for sectionIndex in sections.indices {
                let section = sections[sectionIndex]
                let headerAttributes = PhotosSectionHeaderLayoutAttributes(
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                    with: IndexPath(item: 0, section: sectionIndex)
                )
                if let shortestColumn = columnOffsets.min(by: { $0.height < $1.height }) {
                    /// sticky headers
                    if case .photosSectionCategorization = section.category {
                        let height = PhotosHeaderConstants.font.lineHeight + PhotosHeaderConstants.labelTopPadding + PhotosHeaderConstants.labelBottomPadding
                        var headerFrame = CGRect(
                            x: PhotosConstants.sidePadding,
                            y: shortestColumn.height,
                            width: availableWidth,
                            height: height
                        )
                        headerAttributes.originalYOffset = headerFrame.origin.y /// set it now
                        
                        /// as scroll up, will get larger
                        let contentOffset = collectionView.contentOffset.y + collectionView.adjustedContentInset.top

                        /// negative = scrolled up (origin is higher)
                        let headerOffsetInWindow = headerFrame.origin.y - contentOffset
                        if headerOffsetInWindow < 0 {
                            headerFrame.origin.y = contentOffset
                        }
                        
                        headerAttributes.frame = headerFrame
                        headerAttributes.zIndex = 1
                    }
                }
                
                let layoutAttributes = createLayoutAttributes(itemCount: section.items.count, columnOffsets: &columnOffsets, inside: sectionIndex)
                
                // MARK: Create section

                var categorization: PhotosSectionCategorization?
                if case .photosSectionCategorization(let sectionCategorization) = section.category {
                    categorization = sectionCategorization
                    
                    /// add the categorization to the attributes itself
                    headerAttributes.encompassingCategorizations = [sectionCategorization]
                }
                
                let newSectionLayout = PhotosAttributes.SectionLayout(
                    categorization: categorization,
                    headerLayoutAttributes: headerAttributes,
                    layoutAttributes: layoutAttributes
                )
                
                sectionLayouts.append(newSectionLayout)
            }
            
            /// remove overlapping headers (multiple months in same row)
            var cleanedSectionLayouts = [PhotosAttributes.SectionLayout]()
            for sectionLayoutIndex in sectionLayouts.indices {
                let sectionLayout = sectionLayouts[sectionLayoutIndex]
                
                /// index of a existing section layout where the header frame is the same
                let existingSectionLayoutIndex = cleanedSectionLayouts.firstIndex {
                    /// Sometimes they are very close, so need to check the difference instead of directly using `==`
                    abs($0.headerLayoutAttributes.originalYOffset - sectionLayout.headerLayoutAttributes.originalYOffset) < 0.00001
                }

                if let existingSectionLayoutIndex = existingSectionLayoutIndex {
                    let initialCategorizations = sectionLayouts[existingSectionLayoutIndex].headerLayoutAttributes.encompassingCategorizations
                    if let otherCategorization = sectionLayout.categorization {
                        cleanedSectionLayouts[existingSectionLayoutIndex].headerLayoutAttributes.encompassingCategorizations = initialCategorizations + [otherCategorization]
                    }
                    sectionLayout.headerLayoutAttributes.isVisible = false
                } else {
                    sectionLayout.headerLayoutAttributes.isVisible = true
                }
                
                cleanedSectionLayouts.append(sectionLayout)
            }
            
            /// make headers stick to the bottom once scrolled high enough
            for cleanedSectionLayoutIndex in cleanedSectionLayouts.indices {
                let cleanedSectionLayout = cleanedSectionLayouts[cleanedSectionLayoutIndex]
                
                /// can't just do `cleanedSectionLayouts[safe: cleanedSectionLayoutIndex + 1]` - must check if it's visible first
                let nextCleanedSectionLayouts = cleanedSectionLayouts.dropFirst(cleanedSectionLayoutIndex + 1)
                if let nextCleanedSectionLayout = nextCleanedSectionLayouts.first(where: { $0.headerLayoutAttributes.isVisible }) {
                    let nextStartingY = nextCleanedSectionLayout.headerLayoutAttributes.originalYOffset - PhotosConstants.cellSpacing
                    
                    /// stick to bottom
                    if cleanedSectionLayout.headerLayoutAttributes.frame.maxY > nextStartingY {
                        cleanedSectionLayout.headerLayoutAttributes.frame.origin.y = nextStartingY - cleanedSectionLayout.headerLayoutAttributes.frame.height
                    }
                }
            }
            
            photosAttributes = .sections(cleanedSectionLayouts)
            
        case .photos(let photos):
            let layoutAttributes = createLayoutAttributes(itemCount: photos.count, columnOffsets: &columnOffsets)
            photosAttributes = .attributes(layoutAttributes)
        }
        
        let tallestColumnOffset = columnOffsets.max(by: { $0.height < $1.height }) ?? .zero
        contentSize = CGSize(
            width: collectionView.bounds.width
                - collectionView.safeAreaInsets.left
                - collectionView.safeAreaInsets.right,
            height: tallestColumnOffset.height
        )
        self.photosAttributes = photosAttributes
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if case .sections(let sectionLayouts) = photosAttributes {
            return sectionLayouts[safe: indexPath.section]?.headerLayoutAttributes
        }
        return nil
    }

    /// pass attributes to the collection view flow layout
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        switch photosAttributes {
        case .sections(let sectionLayouts):
            return sectionLayouts[safe: indexPath.section]?.layoutAttributes[safe: indexPath.item]
        case .attributes(let layoutAttributes):
            return layoutAttributes[safe: indexPath.item]
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = [UICollectionViewLayoutAttributes]()
        switch photosAttributes {
        case .sections(let sectionLayouts):
            let layoutAttributes: [[UICollectionViewLayoutAttributes]] = sectionLayouts
                .map { sectionLayout in
                    var attributes = sectionLayout.layoutAttributes
                    attributes.append(sectionLayout.headerLayoutAttributes)
                    return attributes
                }
            attributes = layoutAttributes.flatMap { $0 }
        case .attributes(let layoutAttributes):
            attributes = layoutAttributes
        }
        
        return attributes.filter { rect.intersects($0.frame) }
    }
}
