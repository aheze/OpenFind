//
//  PhotosVC+Find.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/23/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

/// control how to find
enum FindContext {
    case findingAfterNewPhotosAdded
    case findingAfterTextChange(firstTimeShowingResults: Bool)
    
    /// no need to scan again if:
    ///     - photo starred/unstarred
    ///     - photo added via live results
    case justFindFromExistingDoNotScan
}

extension PhotosViewController {
    /// find in all photos, populate `resultsState`, reload collection view
    func find(context: FindContext) {
        print("Find/\(context)")
        if !model.photosToScan.isEmpty, model.scanningState == .dormant {
            switch context {
            case .findingAfterNewPhotosAdded:
                if realmModel.photosScanOnAddition {
                    DispatchQueue.main.async {
                        self.model.startScanning()
                    }
                }
            case .findingAfterTextChange:
                if realmModel.photosScanOnFind {
                    DispatchQueue.main.async {
                        self.model.startScanning()
                    }
                }
            case .justFindFromExistingDoNotScan:
                break
            }
        }
        
        let realmModel = self.realmModel
        let photos = self.model.photos
        let stringToGradients = self.searchViewModel.stringToGradients
        
        Task.detached {
            let (
                allFindPhotos, starredFindPhotos, screenshotsFindPhotos
            ) = Finding.findAndGetFindPhotos(realmModel: realmModel, from: photos, stringToGradients: stringToGradients)
            
            print("Finding and getting.")
            await self.apply(
                allFindPhotos: allFindPhotos,
                starredFindPhotos: starredFindPhotos,
                screenshotsFindPhotos: screenshotsFindPhotos,
                context: context
            )
            
            await MainActor.run {
                self.progressViewModel.finishAutoProgress(shouldShimmer: false)
            }
        }
    }
    
    /// apply the resultsState
    @MainActor func apply(
        allFindPhotos: [FindPhoto],
        starredFindPhotos: [FindPhoto],
        screenshotsFindPhotos: [FindPhoto],
        context: FindContext
    ) {
        guard !searchViewModel.isEmpty else { return }
        
        let displayedFindPhotos: [FindPhoto]
        
        switch self.sliderViewModel.selectedFilter ?? .all {
        case .starred:
            displayedFindPhotos = starredFindPhotos
        case .screenshots:
            displayedFindPhotos = screenshotsFindPhotos
        case .all:
            displayedFindPhotos = allFindPhotos
        }
        
        let (_, columnWidth) = resultsFlowLayout.getColumns(bounds: collectionView.bounds.width, insets: collectionView.safeAreaInsets)
        
        let sizes = getDisplayedCellSizes(from: displayedFindPhotos, columnWidth: columnWidth)
        
        model.resultsState = PhotosResultsState(
            displayedFindPhotos: displayedFindPhotos,
            allFindPhotos: allFindPhotos,
            starredFindPhotos: starredFindPhotos,
            screenshotsFindPhotos: screenshotsFindPhotos,
            displayedCellSizes: sizes
        )
        
        if case .findingAfterTextChange(firstTimeShowingResults: let firstTimeShowingResults) = context {
            updateResults(animate: !firstTimeShowingResults)
        } else {
            updateResults() /// always update results anyway, for example when coming back from star
        }
        
        DispatchQueue.main.async {
            for index in displayedFindPhotos.indices {
                if
                    let cell = self.resultsCollectionView.cellForItem(at: index.indexPath) as? PhotosResultsCell,
                    let findPhoto = displayedFindPhotos[safe: index]
                {
                    self.configureResultsCellDescription(cell: cell, findPhoto: findPhoto)
                }
            }
        }

        let results = model.resultsState?.getResultsText() ?? ""
        resultsHeaderViewModel.text = results
        UIAccessibility.post(notification: .announcement, argument: results)
        
        if model.isSelecting {
            resetSelectingState()
            updateCollectionViewSelectionState()
        }
    }
}
