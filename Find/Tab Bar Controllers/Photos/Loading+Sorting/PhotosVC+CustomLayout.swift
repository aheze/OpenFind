////
////  PhotosVC+CustomLayout.swift
////  Find
////
////  Created by Zheng on 1/6/21.
////  Copyright © 2021 Andrew. All rights reserved.
////
//
//import UIKit
//
//class InvertedStackLayout: UICollectionViewLayout {
//    let cellHeight: CGFloat = 100.00 // Your cell height here...
//
//    override func prepare() {
//        super.prepare()
//    }
//
//    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//        var layoutAttrs = [UICollectionViewLayoutAttributes]()
//
//        if let collectionView = self.collectionView {
//            for section in 0 ..< collectionView.numberOfSections {
//                if let numberOfSectionItems = numberOfItemsInSection(section) {
//                    for item in 0 ..< numberOfSectionItems {
//                        let indexPath = IndexPath(item: item, section: section)
//                        let layoutAttr = layoutAttributesForItem(at: indexPath)
//
//                        if let layoutAttr = layoutAttr, layoutAttr.frame.intersects(rect) {
//                            layoutAttrs.append(layoutAttr)
//                        }
//                    }
//                }
//            }
//        }
//
//        return layoutAttrs
//    }
//
//    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
//        let layoutAttr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
//        let contentSize = self.collectionViewContentSize
//
//        layoutAttr.frame = CGRect(
//            x: 0, y: contentSize.height - CGFloat(indexPath.item + 1) * cellHeight,
//            width: contentSize.width, height: cellHeight)
//
//        return layoutAttr
//    }
//
//    func numberOfItemsInSection(_ section: Int) -> Int? {
//        if let collectionView = self.collectionView,
//            let numSectionItems = collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: section)
//        {
//            return numSectionItems
//        }
//
//        return 0
//    }
//
//    override var collectionViewContentSize: CGSize {
//        get {
//            var height: CGFloat = 0.0
//            var bounds = CGRect.zero
//
//            if let collectionView = self.collectionView {
//                for section in 0 ..< collectionView.numberOfSections {
//                    if let numItems = numberOfItemsInSection(section) {
//                        height += CGFloat(numItems) * cellHeight
//                    }
//                }
//
//                bounds = collectionView.bounds
//            }
//
//            return CGSize(width: bounds.width, height: max(height, bounds.height))
//        }
//    }
//
//    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
//        if let oldBounds = self.collectionView?.bounds,
//            oldBounds.width != newBounds.width || oldBounds.height != newBounds.height
//        {
//            return true
//        }
//
//        return false
//    }
//}
