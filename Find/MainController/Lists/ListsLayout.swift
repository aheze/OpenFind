//
//  ListsLayout.swift
//  Find
//
//  Created by Andrew on 1/20/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

protocol ListLayoutDelegate: AnyObject {
    func collectionView(
    _ collectionView: UICollectionView,
    heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat
    func collectionView(_ collectionView: UICollectionView, heightForDescriptionAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat
}
class ListsLayout: UICollectionViewLayout {

    var insertingIndexPaths = [IndexPath]()
    // 1
    weak var delegate: ListLayoutDelegate?

    // 2
    private let numberOfColumns = 2
    private let cellPadding: CGFloat = 6

    // 3
    private var cache: [UICollectionViewLayoutAttributes] = []

    // 4
    private var contentHeight: CGFloat = 0

    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }

    // 5
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
      super.prepare(forCollectionViewUpdates: updateItems)

      insertingIndexPaths.removeAll()

      for update in updateItems {
        if let indexPath = update.indexPathAfterUpdate,
                           update.updateAction == .insert {
          insertingIndexPaths.append(indexPath)
            print("sppend")
            print(indexPath)
        }
      }
    }
    override func finalizeCollectionViewUpdates() {
      super.finalizeCollectionViewUpdates()

      insertingIndexPaths.removeAll()
    }
    override func initialLayoutAttributesForAppearingItem(
      at itemIndexPath: IndexPath
    ) -> UICollectionViewLayoutAttributes? {
      let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)

        if insertingIndexPaths.contains(itemIndexPath) {
           attributes?.alpha = 0.0
            print(attributes?.center)
            attributes?.center.y = 1000
            print(attributes?.center)
//           attributes?.transform = CGAffineTransform(
//             scaleX: 0.1,
//             y: 0.1
//           )
         }

      return attributes
    }

    override func prepare() {
        
        print("prep")
        print(insertingIndexPaths)
        
      // 1
      guard cache.isEmpty == true || cache.isEmpty == false, let collectionView = collectionView else {
          return
      }
      // 2
      let columnWidth = contentWidth / CGFloat(numberOfColumns)
      var xOffset: [CGFloat] = []
      for column in 0..<numberOfColumns {
        xOffset.append(CGFloat(column) * columnWidth)
      }
      var column = 0
      var yOffset: [CGFloat] = .init(repeating: 0, count: numberOfColumns)
        
      // 3
      for item in 0..<collectionView.numberOfItems(inSection: 0) {
        let indexPath = IndexPath(item: item, section: 0)
          
        // 4
        let photoHeight = delegate?.collectionView(
          collectionView,
          heightForPhotoAtIndexPath: indexPath) ?? 180
        let textHeight = delegate?.collectionView(collectionView, heightForDescriptionAtIndexPath: indexPath, withWidth: columnWidth) ?? 180
        let height = cellPadding * 2 + photoHeight
        let frame = CGRect(x: xOffset[column],
                           y: yOffset[column],
                           width: columnWidth,
                           height: height + textHeight)
        let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
          
        // 5
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.frame = insetFrame
//        if insertingIndexPaths.contains(indexPath) {
//        attributes.alpha = 0.0
//        print(attributes.center)
//        //attributes?.center = CGPoint(x: 0.5, y: 0.5)
//
//        attributes.transform = CGAffineTransform(
//          scaleX: 0.1,
//          y: 0.1
//        )
//        }
        cache.append(attributes)
          
        // 6
        contentHeight = max(contentHeight, frame.maxY)
        yOffset[column] = yOffset[column] + height
        
        column = column < (numberOfColumns - 1) ? (column + 1) : 0
      }
    }

    override func layoutAttributesForElements(in rect: CGRect)
        -> [UICollectionViewLayoutAttributes]? {
      var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
      
      // Loop through the cache and look for items in the rect
      for attributes in cache {
        if attributes.frame.intersects(rect) {
          visibleLayoutAttributes.append(attributes)
        }
      }
            print(insertingIndexPaths)
      return visibleLayoutAttributes
    }
    override func layoutAttributesForItem(at indexPath: IndexPath)
        -> UICollectionViewLayoutAttributes? {
            print(insertingIndexPaths)
      return cache[indexPath.item]
    }

    
    
}
