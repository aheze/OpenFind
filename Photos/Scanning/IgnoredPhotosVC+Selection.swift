//
//  IgnoredPhotosVC+Selection.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/23/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension IgnoredPhotosViewController {
    func toggleSelect() {
        ignoredPhotosViewModel.ignoredPhotosIsSelecting.toggle()
        updateCollectionViewSelectionState()
    }

    func photoSelected(at indexPath: IndexPath) {
        guard let photo = model.ignoredPhotos[safe: indexPath.item] else { return }

        if !ignoredPhotosViewModel.ignoredPhotosSelectedPhotos.contains(photo) {
            ignoredPhotosViewModel.ignoredPhotosSelectedPhotos.append(photo)

            if let cell = collectionView.cellForItem(at: indexPath) as? PhotosCell {
                cell.viewController?.model.selected = true
            }
        }
    }

    func photoDeselected(at indexPath: IndexPath) {
        guard let photo = model.ignoredPhotos[safe: indexPath.item] else { return }
        if ignoredPhotosViewModel.ignoredPhotosSelectedPhotos.contains(photo) {
            ignoredPhotosViewModel.ignoredPhotosSelectedPhotos = ignoredPhotosViewModel.ignoredPhotosSelectedPhotos.filter { $0 != photo }

            if let cell = collectionView.cellForItem(at: indexPath) as? PhotosCell {
                cell.viewController?.model.selected = false
            }
        }
    }

    func getSelectButtonTitle() -> String {
        if ignoredPhotosViewModel.ignoredPhotosIsSelecting {
            return "Done"
        } else {
            return "Select"
        }
    }

    func updateCollectionViewSelectionState() {
        selectBarButton.title = getSelectButtonTitle()
        if !ignoredPhotosViewModel.ignoredPhotosIsSelecting {
            ignoredPhotosViewModel.ignoredPhotosSelectedPhotos = []
        }

        for index in model.ignoredPhotos.indices {
            if let cell = collectionView.cellForItem(at: index.indexPath) as? PhotosCell {
                cell.viewController?.model.showSelectionOverlay = ignoredPhotosViewModel.ignoredPhotosIsSelecting
            }

            if !ignoredPhotosViewModel.ignoredPhotosIsSelecting {
                collectionView.deselectItem(at: index.indexPath, animated: false)
            }
        }
    }
}
