//
//  ListsCollectionFlowLayout.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/8/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//


import UIKit

class ListsCollectionFlowLayout: UICollectionViewFlowLayout {
    
    var layoutAttributes = [UICollectionViewLayoutAttributes]()
    var getLists: (() -> [List])?
    
    /// get the frame of a list cell from available width
    var getListSizeFromWidth: ((CGFloat, List, Int) -> CGSize)?
    
    override init() {
        super.init()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    var contentSize = CGSize.zero /// the scrollable content size of the collection view
    override var collectionViewContentSize: CGSize { return contentSize } /// pass scrollable content size back to the collection view
    
    override func prepare() { /// configure the cells' frames
        super.prepare()
        
        
        guard let lists = getLists?() else { return }
        guard let collectionView = collectionView else { return }
        
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        var currentOffset = CGPoint(x: ListsCollectionConstants.sidePadding, y: 0)
        let availableWidth = collectionView.bounds.width - ListsCollectionConstants.sidePadding * 2
        
        for index in lists.indices {
            if let size = getListSizeFromWidth?(availableWidth, lists[index], index) {
                let cellFrame = CGRect(
                    x: currentOffset.x,
                    y: currentOffset.y,
                    width: availableWidth,
                    height: size.height
                )
                
                let attributes = UICollectionViewLayoutAttributes(forCellWith: index.indexPath)
                attributes.frame = cellFrame
                layoutAttributes.append(attributes)
                currentOffset = currentOffset + CGPoint(x: 0, y: cellFrame.height + ListsCollectionConstants.cellSpacing)
            }
        }
        
        self.contentSize = CGSize(width: collectionView.bounds.width, height: currentOffset.y)
        self.layoutAttributes = layoutAttributes
    }
    
    /// pass attributes to the collection view flow layout
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributes[safe: indexPath.item]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        /// edge cells don't shrink, but the animation is perfect
        return layoutAttributes.filter { rect.intersects($0.frame) } /// try deleting this line
    }
}
