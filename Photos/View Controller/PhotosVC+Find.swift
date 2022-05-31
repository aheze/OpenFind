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
        let findNotesFirst = realmModel.photosResultsFindNotesFirst

        model.currentFindingTask = Task.detached {
            var allFindPhotosNotes = [FindPhoto]()
            var starredFindPhotosNotes = [FindPhoto]()
            var screenshotsFindPhotosNotes = [FindPhoto]()

            if findNotesFirst {
                (
                    allFindPhotosNotes, starredFindPhotosNotes, screenshotsFindPhotosNotes
                ) = Finding.findAndGetFindPhotos(
                    realmModel: realmModel,
                    from: photos,
                    stringToGradients: stringToGradients,
                    scope: .note
                )

                /// only show notes if some were found
                if !allFindPhotosNotes.isEmpty {
                    await self.startApplyingResults(
                        allFindPhotos: allFindPhotosNotes,
                        starredFindPhotos: starredFindPhotosNotes,
                        screenshotsFindPhotos: screenshotsFindPhotosNotes,
                        findingInNotes: true,
                        context: context
                    )
                }
            }

            let (
                allFindPhotosText, starredFindPhotosText, screenshotsFindPhotosText
            ) = Finding.findAndGetFindPhotos(
                realmModel: realmModel,
                from: photos,
                stringToGradients: stringToGradients,
                scope: .text
            )

            if !allFindPhotosNotes.isEmpty, findNotesFirst {
                try await Task.sleep(seconds: realmModel.photosResultsFindTextDelay)
            }

            try Task.checkCancellation()

            await self.startApplyingResults(
                allFindPhotos: (allFindPhotosNotes + allFindPhotosText).uniqued(),
                starredFindPhotos: (starredFindPhotosNotes + starredFindPhotosText).uniqued(),
                screenshotsFindPhotos: (screenshotsFindPhotosNotes + screenshotsFindPhotosText).uniqued(),
                findingInNotes: false,
                context: context
            )

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
        findingInNotes: Bool = false,
        context: FindContext
    ) {
        if model.updateAllowed {
            self.applyResults(
                allFindPhotos: allFindPhotos,
                starredFindPhotos: starredFindPhotos,
                screenshotsFindPhotos: screenshotsFindPhotos,
                findingInNotes: findingInNotes,
                context: context
            )
        } else {
            model.queuedResults.allFindPhotos += allFindPhotos
            model.queuedResults.starredFindPhotos += starredFindPhotos
            model.queuedResults.screenshotsFindPhotos += screenshotsFindPhotos
            model.queuedResults.findingInNotes = findingInNotes
            model.queuedResults.context = context
            model.waitingToAddResults = true
        }
    }

    /// apply results to the results collection view
    @MainActor func applyResults(
        allFindPhotos: [FindPhoto],
        starredFindPhotos: [FindPhoto],
        screenshotsFindPhotos: [FindPhoto],
        findingInNotes: Bool,
        context: FindContext
    ) {
        let timer = TimeElapsed()
        let allFindPhotos = allFindPhotos.uniqued()
        let starredFindPhotos = starredFindPhotos.uniqued()
        let screenshotsFindPhotos = screenshotsFindPhotos.uniqued()

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

        let options: ResultsUpdateOptions = [.postAnnouncement, findingInNotes ? .findingInNotes : .none]
        if case .findingAfterTextChange(firstTimeShowingResults: let firstTimeShowingResults) = context {
            updateResults(animate: !firstTimeShowingResults, options: options)
        } else {
            updateResults(options: options) /// always update results anyway, for example when coming back from star
        }

        /// update highlights if photo was same, but search changed
        reloadVisibleCellResults()

        if model.isSelecting {
            resetSelectingState()
            updateCollectionViewSelectionState()
        }
    }
}
