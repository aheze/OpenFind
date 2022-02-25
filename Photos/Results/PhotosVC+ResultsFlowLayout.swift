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
        
        resultsCollectionView.setCollectionViewLayout(flowLayout, animated: false)
        return flowLayout
    }
    
    func getCellSize(photosIndex: Int, availableWidth: CGFloat) -> CGSize {
        guard let resultsState = model.resultsState else { return .zero }
        let photo = resultsState.findPhotos[photosIndex]
        let c = PhotosResultsCellConstants.self

        let rightTopStackViewHeight = c.resultsFont.lineHeight
            + c.resultsLabelEdgeInsets.top
            + c.resultsLabelEdgeInsets.bottom
        
        let rightStackViewSpacing = c.cellSpacing
        
        let contentWidth = availableWidth - (c.cellPadding * 2)
        let descriptionWidth = contentWidth - c.imageWidth - c.cellSpacing
        let descriptionHeight = photo.descriptionText.height(withConstrainedWidth: descriptionWidth, font: c.descriptionFont)
        
        let contentHeight = rightTopStackViewHeight + rightStackViewSpacing + descriptionHeight
        let height = contentHeight + c.cellPadding * 2
        
        let cellSize = CGSize(width: availableWidth, height: height)
        return cellSize
    }
}
