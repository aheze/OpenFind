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
        model.currentFindingTask?.cancel()

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

        model.currentFindingTask = Task.detached {
            let (
                allFindPhotosNotes, starredFindPhotosNotes, screenshotsFindPhotosNotes
            ) = Finding.findAndGetFindPhotos(
                realmModel: realmModel,
                from: photos,
                stringToGradients: stringToGradients,
                scope: .note
            )

            await self.startApplyingResults(
                allFindPhotos: allFindPhotosNotes,
                starredFindPhotos: starredFindPhotosNotes,
                screenshotsFindPhotos: screenshotsFindPhotosNotes,
                context: context
            )
            print("Applied notes/")

            let (
                allFindPhotosText, starredFindPhotosText, screenshotsFindPhotosText
            ) = Finding.findAndGetFindPhotos(
                realmModel: realmModel,
                from: photos,
                stringToGradients: stringToGradients,
                scope: .text
            )

            try await Task.sleep(seconds: 1.2)
            try Task.checkCancellation()

            await self.startApplyingResults(
                allFindPhotos: FindPhoto.merge(allFindPhotosNotes + allFindPhotosText).filterHasResults(),
                starredFindPhotos: FindPhoto.merge(starredFindPhotosNotes + starredFindPhotosText).filterHasResults(),
                screenshotsFindPhotos: FindPhoto.merge(screenshotsFindPhotosNotes + screenshotsFindPhotosText).filterHasResults(),
                context: context
            )
            print("Applied reults/")

            await MainActor.run {
                self.progressViewModel.finishAutoProgress(shouldShimmer: false)
            }
        }
    }

    /// queue if needed
    @MainActor func startApplyingResults(
        allFindPhotos: [FindPhoto],
        starredFindPhotos: [FindPhoto],
        screenshotsFindPhotos: [FindPhoto],
        context: FindContext
    ) {
        if model.updateAllowed {
            self.applyResults(
                allFindPhotos: allFindPhotos,
                starredFindPhotos: starredFindPhotos,
                screenshotsFindPhotos: screenshotsFindPhotos,
                context: context
            )
        } else {
            model.queuedAllResults += allFindPhotos
            model.queuedStarredResults += starredFindPhotos
            model.queuedScreenshotsResults += screenshotsFindPhotos
            model.queuedResultsContext = context
            model.waitingToAddResults = true
        }
    }

    /// apply results to the results collection view
    @MainActor func applyResults(
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

        /// update highlights if photo was same, but search changed
        reloadVisibleCellResults()

        let results = model.resultsState?.getResultsText() ?? ""
        resultsHeaderViewModel.text = results
        UIAccessibility.post(notification: .announcement, argument: results)

        if model.isSelecting {
            resetSelectingState()
            updateCollectionViewSelectionState()
        }
    }
}
