////
////  ListsLayout.swift
////  Find
////
////  Created by Andrew on 1/20/20.
////  Copyright © 2020 Andrew. All rights reserved.
////
//

//
// Created by Dmitry Marinin on 2019-03-04.
// Copyright (c) 2019. All rights reserved.
//
import UIKit

protocol AdaptiveCollectionLayoutDelegate: class {
    // Declare a protocol for provide cell height
    func collectionView(_ collectionView: UICollectionView, heightForTextAtIndexPath indexPath: IndexPath) -> CGFloat
}

enum AdaptiveCollectionConfig {
    static let bannerHeight: CGFloat = 120
    static let placeholderHeight: CGFloat = 210
    static var cellBaseHeight: CGFloat = 159
    static let numberOfColumns = 2
    static var cellPadding: CGFloat {
        return UIDevice.isPhoneSE ? 4 : 8
    }
}

// If you prefer you can add it too
extension UIDevice {
    static var isPhoneSE: Bool {
        let screenWidth = screenBounds.width
        return screenWidth == 320
    }
}

class AdaptiveCollectionLayout: UICollectionViewLayout {
    weak var delegate: AdaptiveCollectionLayoutDelegate!
    // Cache is array of matrix with coordinates cell in X,Y
    // It will provide coordinates for visibility cell for UIKit
    // We can change it, as how we want
    fileprivate var cache = [UICollectionViewLayoutAttributes]()
    // Determinate height of content after first loop
    // Increment as content cell are added
    
    fileprivate var contentHeight: CGFloat = 0

    fileprivate var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }

    // Method to return the size of the collection view’s contents
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }

    override func prepare() {
        super.prepare()
        // Need to clear cache for invalidate layout
        cache.removeAll()

        guard cache.isEmpty, let collectionView = collectionView else {
            return
        }
        contentHeight = collectionView.frame.size.height
        // If we had 2 sections we generate first elements and than get that offset and call it again
        // For example first section is "onboarding"
        if collectionView.numberOfSections > 1 {
            let lastSection = collectionView.numberOfSections - 1
            let yOffset = prepareForMain(collectionView: collectionView, section: 0, numberOfColumns: 1)
            _ = prepareForMain(collectionView: collectionView, section: lastSection, numberOfColumns: AdaptiveCollectionConfig.numberOfColumns, inYOffset: yOffset)
        } else {
            _ = prepareForMain(collectionView: collectionView, section: 0, numberOfColumns: AdaptiveCollectionConfig.numberOfColumns)
        }
    }

    func prepareForMain(collectionView: UICollectionView, section: Int, numberOfColumns: Int, inYOffset: CGFloat? = nil) -> CGFloat? {
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset = [CGFloat]()
        for column in 0..<numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        var column = 0
        var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)

        if let inYOff = inYOffset {
            for index in 0..<numberOfColumns {
                yOffset[index] = inYOff
            }
        }

        for item in 0..<collectionView.numberOfItems(inSection: section) {
            let indexPath = IndexPath(item: item, section: section)

            let descriptionHeight = delegate.collectionView(collectionView, heightForTextAtIndexPath: indexPath)
            let height = AdaptiveCollectionConfig.cellPadding * 2 + descriptionHeight
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
            let insetFrame = frame.insetBy(
                dx: AdaptiveCollectionConfig.cellPadding,
                dy: AdaptiveCollectionConfig.cellPadding
            )

            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)

            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height

            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        }
        return yOffset.last
    }

    // Here you simply retrieve and return from cache the layout attributes which correspond to the requested indexPath
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }

    // Determine which items are visible in the given rect.
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()

        // Loop through the cache and look for items in the rect
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
}

extension UICollectionViewFlowLayout {
    override open func invalidationContext(forInteractivelyMovingItems targetIndexPaths: [IndexPath], withTargetPosition targetPosition: CGPoint, previousIndexPaths: [IndexPath], previousPosition: CGPoint) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forInteractivelyMovingItems: targetIndexPaths, withTargetPosition: targetPosition, previousIndexPaths: previousIndexPaths, previousPosition: previousPosition)

        // Check that the movement has actually happeneds
        if previousIndexPaths.first!.item != targetIndexPaths.first!.item {
            collectionView?.dataSource?.collectionView?(collectionView!, moveItemAt: previousIndexPaths.first!, to: targetIndexPaths.last!)
        }

        return context
    }

    override open func invalidationContextForEndingInteractiveMovementOfItems(toFinalIndexPaths indexPaths: [IndexPath], previousIndexPaths: [IndexPath], movementCancelled: Bool) -> UICollectionViewLayoutInvalidationContext {
        return super.invalidationContextForEndingInteractiveMovementOfItems(toFinalIndexPaths: indexPaths, previousIndexPaths: previousIndexPaths, movementCancelled: movementCancelled)
    }

    // @available(iOS 9.0, *) //If you'd like to apply some formatting as the dimming of the movable cell
    override open func layoutAttributesForInteractivelyMovingItem(at indexPath: IndexPath, withTargetPosition position: CGPoint) -> UICollectionViewLayoutAttributes {
        let attributes = super.layoutAttributesForInteractivelyMovingItem(at: indexPath, withTargetPosition: position)
        attributes.alpha = 0.8
        return attributes
    }
}
