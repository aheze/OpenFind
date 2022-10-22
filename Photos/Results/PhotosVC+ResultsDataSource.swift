//
//  PhotosVC+ResultsDataSource.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/23/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Photos
import SwiftUI

struct ResultsUpdateOptions: OptionSet {
    let rawValue: Int

    /// Dismiss the popover when the user taps outside.
    static let postAnnouncement = Self(rawValue: 1 << 0) // 1

    /// Dismiss the popover when the user drags it down.
    static let findingInNotes = Self(rawValue: 1 << 1) // 2

    /// Don't automatically dismiss the popover.
    static let none = Self([])
}

extension PhotosViewController {
    func updateResults(animate: Bool = true, options: ResultsUpdateOptions = .none) {
        guard let resultsState = model.resultsState else { return }
        var resultsSnapshot = ResultsSnapshot()
        let section = DataSourceSectionTemplate()
        resultsSnapshot.appendSections([section])
        resultsSnapshot.appendItems(resultsState.displayedFindPhotos, toSection: section)
        resultsDataSource.apply(resultsSnapshot, animatingDifferences: animate)

        let findingInNotes = options.contains(.findingInNotes)
        let message = self.getMessage(
            findingInNotes: findingInNotes,
            selectedFilter: sliderViewModel.selectedFilter ?? .all
        )

        resultsHeaderViewModel.text = message

        if options.contains(.postAnnouncement) {
            UIAccessibility.post(notification: .announcement, argument: message)
        }

        if model.scannedPhotosCount == model.totalPhotosCount {
            resultsHeaderViewModel.description = nil
        } else {
            resultsHeaderViewModel.description = ResultsHeaderViewModel.defaultDescription
        }

        updateCounts(
            allCount: resultsState.allFindPhotos.count,
            starredCount: resultsState.starredFindPhotos.count,
            screenshotsCount: resultsState.screenshotsFindPhotos.count
        )

        updateViewsEnabled()
    }

    func getMessage(findingInNotes: Bool, selectedFilter: SliderViewModel.Filter) -> String {
        let count = model.resultsState?.displayedFindPhotos.count ?? 0
        if findingInNotes {
            switch selectedFilter {
            case .starred:
                return count == 1 ? "Found notes in 1 starred photo." : "Found notes in \(count) starred photos."
            case .screenshots:
                return count == 1 ? "Found notes in 1 screenshots." : "Found notes in \(count) screenshots."
            case .all:
                return count == 1 ? "Found notes in 1 photo." : "Found notes in \(count) photos."
            }
        } else {
            switch selectedFilter {
            case .starred:
                return count == 1 ? "1 starred photo." : "\(count) starred photos."
            case .screenshots:
                return count == 1 ? "1 screenshot." : "\(count) screenshots."
            case .all:
                return count == 1 ? "1 photo." : "\(count) photos."
            }
        }
    }

    /// reload the collection view at an index path.
    func updateResults(at index: Int, with metadata: PhotoMetadata) {
        if let cell = resultsCollectionView.cellForItem(at: index.indexPath) as? PhotosCellResults {
            cell.model.photo?.metadata = metadata
        }
    }

    func reloadVisibleCellResults() {
        guard let displayedFindPhotos = model.resultsState?.displayedFindPhotos else { return }
        for index in displayedFindPhotos.indices {
            if
                let cell = self.resultsCollectionView.cellForItem(at: index.indexPath) as? PhotosCellResults,
                cell.containerView != nil,
                var findPhoto = self.model.resultsState?.displayedFindPhotos[safe: index]
            {
                findPhoto.description = nil
                configureCellResultsDescription(cell: cell, findPhoto: findPhoto)
            }
        }
    }

    func configureCellResults(cell: PhotosCellResults, indexPath: IndexPath) {
        guard
            let resultsState = model.resultsState,
            let findPhoto = resultsState.displayedFindPhotos[safe: indexPath.item]
        else { return }

        DispatchQueue.main.async {
            cell.model.image = nil

            if cell.containerView == nil {
                cell.realmModel = self.realmModel
                let contentView = PhotosCellResultsImageView(
                    model: cell.model,
                    resultsModel: cell.resultsModel,
                    textModel: cell.textModel,
                    highlightsViewModel: cell.highlightsViewModel,
                    realmModel: self.realmModel
                )
                let hostingController = UIHostingController(rootView: contentView)
                hostingController.view.backgroundColor = .clear
                cell.contentView.addSubview(hostingController.view)
                hostingController.view.pinEdgesToSuperview()
                cell.containerView = hostingController.view
            }

            cell.highlightsViewModel.highlights.removeAll()
            cell.resultsModel.findPhoto = findPhoto
            cell.model.photo = findPhoto.photo

            let selected = self.model.isSelecting && self.model.selectedPhotos.contains(findPhoto.photo)
            cell.model.selected = selected

            cell.representedAssetIdentifier = findPhoto.photo.asset.localIdentifier

            cell.fetchingID = self.model.getImage(
                from: findPhoto.photo.asset,
                targetSize: CGSize(width: 300, height: 300)
            ) { [weak cell] image in
                // UIKit may have recycled this cell by the handler's activation time.
                // Set the cell's thumbnail image only if it's still showing the same asset.
                if cell?.representedAssetIdentifier == findPhoto.photo.asset.localIdentifier {
                    cell?.model.image = image
                }
            }

            self.configureCellResultsDescription(cell: cell, findPhoto: findPhoto)
        }
    }

    func teardownCellResults(cell: PhotosCellResults, indexPath: IndexPath) {
        if let id = cell.fetchingID {
            cell.fetchingID = nil
            model.imageManager.cancelImageRequest(id)
        }
    }

    /// call after bounds or filter change
    /// Only works when `resultsState` isn't nil
    /// If add completion, must call `updateResults()` later.
    /// If completion is `nil`, `invalidateLayout` will be called.
    func updateResultsCellSizes(completion: (() -> Void)? = nil) {
        if let displayedFindPhotos = model.resultsState?.displayedFindPhotos {
            let (_, columnWidth) = resultsFlowLayout.getColumns(bounds: resultsCollectionView.bounds.width, insets: resultsCollectionView.safeAreaInsets)

            DispatchQueue.global(qos: .userInitiated).async {
                let sizes = self.getDisplayedCellSizes(from: displayedFindPhotos, columnWidth: columnWidth)

                DispatchQueue.main.async {
                    self.model.resultsState?.displayedCellSizes = sizes
                    if let completion = completion {
                        completion()
                    } else {
                        self.resultsFlowLayout.invalidateLayout()
                    }
                }
            }
        }
    }

    func makeResultsDataSource() -> ResultsDataSource {
        let dataSource = ResultsDataSource(collectionView: resultsCollectionView) { collectionView, indexPath, cachedFindPhoto -> UICollectionViewCell? in

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "PhotosCellResults",
                for: indexPath
            ) as! PhotosCellResults

            return cell
        }

        return dataSource
    }
}
