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
        var height = CGFloat(100)
        if let photosResultsCellLayout = Settings.Values.PhotosResultsCellLayout(rawValue: realmModel.photosResultsCellLayout) {
            height = photosResultsCellLayout.getCellHeight()
        }
        
        var sizes = Array(repeating: CGSize(width: columnWidth, height: height), count: displayedFindPhotos.count)
        for index in displayedFindPhotos.indices {
            let photo = displayedFindPhotos[index].photo
            if let note = realmModel.container.getNote(from: photo.asset.localIdentifier), !note.string.isEmpty {
                var height = sizes[index].height
                height += PhotosResultsCellConstants.noteHeight + PhotosResultsCellConstants.rightSpacing
                sizes[index].height = height
            }
        }
        
        return sizes
    }
}
