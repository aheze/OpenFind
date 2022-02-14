//
//  PhotosCollectionFlowLayout.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/14/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

class PhotosCollectionFlowLayout: UICollectionViewFlowLayout {
    var model: PhotosViewModel
    
    init(model: PhotosViewModel) {
        self.model = model
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
    var columnWidth = CGFloat(0) /// width of each column. Needed for bounds change calculations
    override var collectionViewContentSize: CGSize { return contentSize } /// pass scrollable content size back to the collection view
    
    override func prepare() { /// configure the cells' frames
        super.prepare()
    }
}
