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

struct AdaptiveCollectionConfig {
    
    static let bannerHeight: CGFloat = 120
    static let placeholderHeight: CGFloat = 210
    static var cellBaseHeight: CGFloat = 159
    static let numberOfColumns = 2
    static var cellPadding: CGFloat {
        return UIDevice.isPhoneSE ? 4 : 8
    }
}


//If you prefer you can add it too
extension UIDevice {
    
    static var isPhoneSE: Bool {
        let screenWidth = UIScreen.main.bounds.width
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
        //print("1++++++++")
        // Need to clear cache for invalidate layout
        self.cache.removeAll()

        guard cache.isEmpty, let collectionView = collectionView else {
            return
        }
        contentHeight = collectionView.frame.size.height
        // If we had 2 sections we generate first elements and than get that offset and call it again
        // For example first section is "onboarding"
        if collectionView.numberOfSections > 1 {
            let lastSection = collectionView.numberOfSections - 1
            let yOffset = prepareForMain(collectionView: collectionView, section: 0, numberOfColumns: 1)
            let _ = prepareForMain(collectionView: collectionView, section: lastSection, numberOfColumns: AdaptiveCollectionConfig.numberOfColumns, inYOffset: yOffset)
        } else {
            let _ = prepareForMain(collectionView: collectionView, section: 0, numberOfColumns: AdaptiveCollectionConfig.numberOfColumns)
        }
    }

    func prepareForMain(collectionView: UICollectionView, section: Int, numberOfColumns: Int, inYOffset: CGFloat? = nil) -> CGFloat? {
        //print("2++++++++")
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
                dy: AdaptiveCollectionConfig.cellPadding)

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
//import UIKit
//
//protocol ListLayoutDelegate: AnyObject {
//    func collectionView(
//    _ collectionView: UICollectionView,
//    heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat
//    func collectionView(_ collectionView: UICollectionView, heightForDescriptionAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat
//}
//class ListsLayout: UICollectionViewLayout {
//
//    var insertingIndexPaths = [IndexPath]()
//    // 1
//    weak var delegate: ListLayoutDelegate?
//
//    // 2
//    private let numberOfColumns = 2
//    private let cellPadding: CGFloat = 6
//
//    // 3
//    private var cache: [UICollectionViewLayoutAttributes] = []
//
//    // 4
//    private var contentHeight: CGFloat = 0
//
//    private var contentWidth: CGFloat {
//        guard let collectionView = collectionView else {
//            return 0
//        }
//        let insets = collectionView.contentInset
//        return collectionView.bounds.width - (insets.left + insets.right)
//    }
//
//    // 5
//    override var collectionViewContentSize: CGSize {
//        return CGSize(width: contentWidth, height: contentHeight)
//    }
//
//    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
//      super.prepare(forCollectionViewUpdates: updateItems)
//
//      insertingIndexPaths.removeAll()
//
//      for update in updateItems {
//        if let indexPath = update.indexPathAfterUpdate,
//                           update.updateAction == .insert {
//          insertingIndexPaths.append(indexPath)
//            print("sppend")
//            print(indexPath)
//        }
//      }
//    }
//    override func finalizeCollectionViewUpdates() {
//      super.finalizeCollectionViewUpdates()
//
//      insertingIndexPaths.removeAll()
//    }
//    override func initialLayoutAttributesForAppearingItem(
//      at itemIndexPath: IndexPath
//    ) -> UICollectionViewLayoutAttributes? {
//      let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
//
//        if insertingIndexPaths.contains(itemIndexPath) {
//           attributes?.alpha = 0.0
//            print(attributes?.center)
//            attributes?.center.y = 1000
//            print(attributes?.center)
////           attributes?.transform = CGAffineTransform(
////             scaleX: 0.1,
////             y: 0.1
////           )
//         }
//
//      return attributes
//    }
//
//    override func prepare() {
//
//        print("prep")
//        print(insertingIndexPaths)
//
//      // 1
//      guard cache.isEmpty == true || cache.isEmpty == false, let collectionView = collectionView else {
//          return
//      }
//      // 2
//      let columnWidth = contentWidth / CGFloat(numberOfColumns)
//      var xOffset: [CGFloat] = []
//      for column in 0..<numberOfColumns {
//        xOffset.append(CGFloat(column) * columnWidth)
//      }
//      var column = 0
//      var yOffset: [CGFloat] = .init(repeating: 0, count: numberOfColumns)
//
//      // 3
//      for item in 0..<collectionView.numberOfItems(inSection: 0) {
//        let indexPath = IndexPath(item: item, section: 0)
//
//        // 4
//        let photoHeight = delegate?.collectionView(
//          collectionView,
//          heightForPhotoAtIndexPath: indexPath) ?? 180
//        let textHeight = delegate?.collectionView(collectionView, heightForDescriptionAtIndexPath: indexPath, withWidth: columnWidth) ?? 180
//        let height = cellPadding * 2 + photoHeight
//        let frame = CGRect(x: xOffset[column],
//                           y: yOffset[column],
//                           width: columnWidth,
//                           height: height + textHeight)
//        let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
//
//        // 5
//        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
//        attributes.frame = insetFrame
////        if insertingIndexPaths.contains(indexPath) {
////        attributes.alpha = 0.0
////        print(attributes.center)
////        //attributes?.center = CGPoint(x: 0.5, y: 0.5)
////
////        attributes.transform = CGAffineTransform(
////          scaleX: 0.1,
////          y: 0.1
////        )
////        }
//        cache.append(attributes)
//
//        // 6
//        contentHeight = max(contentHeight, frame.maxY)
//        yOffset[column] = yOffset[column] + height
//
//        column = column < (numberOfColumns - 1) ? (column + 1) : 0
//      }
//    }
//
//    override func layoutAttributesForElements(in rect: CGRect)
//        -> [UICollectionViewLayoutAttributes]? {
//      var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
//
//      // Loop through the cache and look for items in the rect
//      for attributes in cache {
//        if attributes.frame.intersects(rect) {
//          visibleLayoutAttributes.append(attributes)
//        }
//      }
//            print(insertingIndexPaths)
//      return visibleLayoutAttributes
//    }
//    override func layoutAttributesForItem(at indexPath: IndexPath)
//        -> UICollectionViewLayoutAttributes? {
//            print(insertingIndexPaths)
//      return cache[indexPath.item]
//    }
//
//
//
//}
extension UICollectionViewFlowLayout {
    open override func invalidationContext(forInteractivelyMovingItems targetIndexPaths: [IndexPath], withTargetPosition targetPosition: CGPoint, previousIndexPaths: [IndexPath], previousPosition: CGPoint) -> UICollectionViewLayoutInvalidationContext {

        let context = super.invalidationContext(forInteractivelyMovingItems: targetIndexPaths, withTargetPosition: targetPosition, previousIndexPaths: previousIndexPaths, previousPosition: previousPosition)

        //Check that the movement has actually happeneds
        if previousIndexPaths.first!.item != targetIndexPaths.first!.item {
            collectionView?.dataSource?.collectionView?(collectionView!, moveItemAt: previousIndexPaths.first!, to: targetIndexPaths.last!)
        }

        return context
    }

    open override func invalidationContextForEndingInteractiveMovementOfItems(toFinalIndexPaths indexPaths: [IndexPath], previousIndexPaths: [IndexPath], movementCancelled: Bool) -> UICollectionViewLayoutInvalidationContext {
        return super.invalidationContextForEndingInteractiveMovementOfItems(toFinalIndexPaths: indexPaths, previousIndexPaths: previousIndexPaths, movementCancelled: movementCancelled)
    }

    //@available(iOS 9.0, *) //If you'd like to apply some formatting as the dimming of the movable cell
    open override func layoutAttributesForInteractivelyMovingItem(at indexPath: IndexPath, withTargetPosition position: CGPoint) -> UICollectionViewLayoutAttributes {
        let attributes = super.layoutAttributesForInteractivelyMovingItem(at: indexPath, withTargetPosition: position)
        attributes.alpha = 0.8
        return attributes
    }
}
