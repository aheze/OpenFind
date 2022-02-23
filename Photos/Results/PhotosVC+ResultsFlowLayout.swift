//
//  PhotosVC+ResultsDataSource.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/23/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

extension PhotosViewController {
    func createFlowLayout() -> ListsCollectionFlowLayout {
        let flowLayout = ListsCollectionFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.getIndices = { [weak self] in
            if
                let self = self,
                let resultsState = self.model.resultsState
            {
                return Array(resultsState.findPhotos.indices)
            }
            return []
        }
        flowLayout.getSizeForIndexWithWidth = { [weak self] listIndex, availableWidth in
            guard let self = self else { return .zero }
            return self.getCellSize(photosIndex: listIndex, availableWidth: availableWidth)
        }
        
        collectionView.setCollectionViewLayout(flowLayout, animated: false)
        return flowLayout
    }
    
    func getCellSize(photosIndex: Int, availableWidth: CGFloat) -> CGSize {
        guard let resultsState = self.model.resultsState else { return .zero }
//        let photo = resultsState.findPhotos[photosIndex]
//        let c = ListsCellConstants.self
//
//        let headerHeight = c.headerTitleFont.lineHeight
//            + c.headerEdgeInsets.top
//            + c.headerEdgeInsets.bottom
//
//        let contentWidth = availableWidth
//            - c.contentEdgeInsets.left
//            - c.contentEdgeInsets.right
//
////        let chipContainerHeight = offset.height + (chipFrames.last?.frame.height ?? 0)
////        let containerHeight = chipContainerHeight
////            + c.contentEdgeInsets.top
////            + c.contentEdgeInsets.bottom
//
//        let height = headerHeight
//        + containerHeight
//        let cellSize = CGSize(width: availableWidth, height: height)
        let cellSize = CGSize(width: availableWidth, height: 300)
        return cellSize
    }
}
