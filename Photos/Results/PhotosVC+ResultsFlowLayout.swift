//
//  PhotosVC+ResultsDataSource.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/23/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

extension PhotosViewController {
    func makeResultsFlowLayout() -> ListsCollectionFlowLayout {
        let flowLayout = ListsCollectionFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.getSections = { [weak self] in

            guard
                let self = self,
                let resultsState = self.model.resultsState
            else { return [] }
            
            let section = Section(
                items: Array(
                    repeating: Section.Item.placeholder,
                    count: resultsState.displayedFindPhotos.count
                )
            )
            return [section]
        }
        
        flowLayout.getTopPadding = { [weak self] in
            if
                let self = self,
                let size = self.headerContentModel.size
            {
                return size.height
            }
            return .zero
        }
        
        flowLayout.getSizeForIndexWithWidth = { [weak self] photosIndex, availableWidth in
            guard let self = self else { return .zero }
            return self.getCellSize(photosIndex: photosIndex, availableWidth: availableWidth)
        }
        
        resultsCollectionView.setCollectionViewLayout(flowLayout, animated: false)
        return flowLayout
    }
    
    func getCellSize(photosIndex: Int, availableWidth: CGFloat) -> CGSize {
        guard let resultsState = model.resultsState else { return .zero }
        let photo = resultsState.displayedFindPhotos[photosIndex]
        let c = PhotosResultsCellConstants.self

        let rightTopStackViewHeight = c.resultsFont.lineHeight
            + c.resultsLabelEdgeInsets.top
            + c.resultsLabelEdgeInsets.bottom
        
        let rightStackViewSpacing = c.cellSpacing
        
        let contentWidth = availableWidth - (c.cellPadding * 2)
        let descriptionWidth = contentWidth - c.leftContainerWidth - c.cellSpacing
        let descriptionHeight = photo.descriptionText.height(withConstrainedWidth: descriptionWidth, font: c.descriptionFont)
        
        let contentHeight = rightTopStackViewHeight + rightStackViewSpacing + descriptionHeight
        let height = contentHeight + c.cellPadding * 2
        
        let cellSize = CGSize(width: availableWidth, height: height)
        return cellSize
    }
}
