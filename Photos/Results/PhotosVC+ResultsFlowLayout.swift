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
            return self.model.resultsState?.displayedCellSizes[safe: photosIndex] ?? .zero
        }
        
        resultsCollectionView.setCollectionViewLayout(flowLayout, animated: false)
        return flowLayout
    }
    
    /// calculate and update the sizes of results cells
    func getDisplayedCellSizes(from displayedFindPhotos: [FindPhoto], columnWidth: CGFloat) -> [CGSize] {
        var textHeight = CGFloat(0)
        if let photosResultsCellLayout = Settings.Values.PhotosResultsCellLayout(rawValue: realmModel.photosResultsCellLayout) {
            textHeight += photosResultsCellLayout.getCellHeight()
        }
        
        var sizes = [CGSize]()
        for index in displayedFindPhotos.indices {
            let findPhoto = displayedFindPhotos[index]
            
            guard let fastDescription = findPhoto.fastDescription else { continue }
            
            var height = CGFloat(40)
            
            if fastDescription.containsResultsInText {
                height += textHeight
                
                if fastDescription.containsNote {
                    height += PhotosResultsCellConstants.noteHeight + PhotosResultsCellConstants.rightSpacing
                }
            } else if fastDescription.containsNote {
                height += PhotosResultsCellConstants.noteHeight
            }
            
            let size = CGSize(width: columnWidth, height: height)
            sizes.append(size)
        }
        
        return sizes
    }
}
