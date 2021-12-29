//
//  RAMCollectionViewLayout.swift
//  RAMReel
//
//  Created by Mikhail Stepkin on 4/9/15.
//  Copyright (c) 2015 Ramotion. All rights reserved.
//

import UIKit

/**
 Example collection view layout
 */
@objc(RAMCollectionViewLayout)
class RAMCollectionViewLayout: UICollectionViewFlowLayout {
    override internal func prepare() {
        super.prepare()
        
        updateInsets()
    }
    
    func updateInsets() {
        if let collectionView = collectionView {
            let insets = (collectionView.bounds.height - itemHeight) / 2
            collectionView.contentInset = UIEdgeInsets(top: insets, left: 0, bottom: insets, right: 0)
        }
    }
    
    override internal func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributesForItem(at: itemIndexPath)
    }

    override internal func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        modifyLayoutAttributes(attributes)
        
        return attributes
    }

    override internal func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var allAttributesInRect = [(UICollectionViewLayoutAttributes, CGFloat)]()
        
        if let numberOfItems = collectionView?.numberOfItems(inSection: 0) {
            for item in 0..<numberOfItems {
                let indexPath = IndexPath(item: item, section: 0)
                
                let attributes = layoutAttributesForItem(at: indexPath)
                
                if rect.intersects(attributes.frame) {
                    let intersection = rect.intersection(attributes.frame)
                    allAttributesInRect.append((attributes, intersection.area))
                }
            }
        }
        
        allAttributesInRect.sort {
            let (_, a1) = $0
            let (_, a2) = $1
            
            return a1 > a2
        }
        
        let attributes = allAttributesInRect.map { attr, _ in
            attr
        }

        return attributes
    }
    
    var itemHeight: CGFloat = 44
    func modifyLayoutAttributes(_ layoutattributes: UICollectionViewLayoutAttributes) {
        if
            let collectionView = collectionView
        {
            var frame = layoutattributes.frame
            frame.size.height = itemHeight
            frame.size.width = collectionView.bounds.width
            frame.origin.x = collectionView.bounds.origin.x
            frame.origin.y = itemHeight * CGFloat((layoutattributes.indexPath as NSIndexPath).item)
            layoutattributes.frame = frame
        }
    }

    override internal var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else {
            return CGSize.zero
        }
        
        let number = collectionView.numberOfItems(inSection: 0)
        let height = CGFloat(number) * itemHeight
        
        let size = CGSize(width: collectionView.bounds.width, height: height)
        return size
    }
}

private extension CGRect {
    var area: CGFloat {
        return height * width
    }
}
