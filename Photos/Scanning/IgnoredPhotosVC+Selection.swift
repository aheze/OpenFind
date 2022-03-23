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
        model.ignoredPhotosIsSelecting.toggle()
        updateCollectionViewSelectionState()
    }

    func photoSelected(at indexPath: IndexPath) {
        guard let photo = model.ignoredPhotos[safe: indexPath.item] else { return }
        if !model.ignoredPhotosSelectedPhotos.contains(photo) {
            model.ignoredPhotosSelectedPhotos.append(photo)

            if let cell = collectionView.cellForItem(at: indexPath) as? PhotosCollectionCell {
                configureCellSelection(cell: cell, selected: true)
            }
        }
    }

    func photoDeselected(at indexPath: IndexPath) {
        guard let photo = model.ignoredPhotos[safe: indexPath.item] else { return }
        if model.ignoredPhotosSelectedPhotos.contains(photo) {
            model.ignoredPhotosSelectedPhotos = model.ignoredPhotosSelectedPhotos.filter { $0 != photo }

            if let cell = collectionView.cellForItem(at: indexPath) as? PhotosCollectionCell {
                configureCellSelection(cell: cell, selected: false)
            }
        }
    }

    func updateCollectionViewSelectionState() {
        if model.ignoredPhotosIsSelecting {
            selectBarButton.title = "Done"
        } else {
            selectBarButton.title = "Select"
            model.selectedPhotos = []
        }

        for index in model.ignoredPhotos.indices {
            if let cell = collectionView.cellForItem(at: index.indexPath) as? PhotosCollectionCell {
                if model.ignoredPhotosIsSelecting {
                    cell.buttonView.isUserInteractionEnabled = false
                    cell.selectOverlayIconView.setState(.hidden)
                    UIView.animate(withDuration: ListsCellConstants.editAnimationDuration) {
                        cell.selectOverlayView.alpha = 1
                    }
                } else {
                    cell.buttonView.isUserInteractionEnabled = true
                    UIView.animate(withDuration: ListsCellConstants.editAnimationDuration) {
                        cell.selectOverlayView.backgroundColor = .clear
                        cell.selectOverlayView.alpha = 0
                    }
                    collectionView.deselectItem(at: index.indexPath, animated: false)
                }
            }
        }
    }

    func configureCellSelection(cell: PhotosCollectionCell, selected: Bool) {
        cell.selectOverlayIconView.setState(selected ? .selected : .hidden)
        cell.selectOverlayView.backgroundColor = selected ? PhotosCellConstants.selectedBackgroundColor : .clear
    }
}
