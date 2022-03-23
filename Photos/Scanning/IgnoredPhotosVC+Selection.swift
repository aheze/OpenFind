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

    /// toggle select
    func photoTapped(photo: Photo) {
        let photoSelected: Bool
        if model.ignoredPhotosSelectedPhotos.contains(photo) {
            model.ignoredPhotosSelectedPhotos = model.ignoredPhotosSelectedPhotos.filter { $0 != photo }
            photoSelected = false
        } else {
            model.ignoredPhotosSelectedPhotos.append(photo)
            photoSelected = true
        }

        if
            let indexPath = model.ignoredPhotos.firstIndex(of: photo)?.indexPath,
            let cell = collectionView.cellForItem(at: indexPath) as? PhotosCollectionCell
        {
            cell.selectOverlayIconView.setState(photoSelected ? .selected : .hidden)
            cell.selectOverlayView.backgroundColor = photoSelected ? PhotosCellConstants.selectedBackgroundColor : .clear
        }
    }

    func updateCollectionViewSelectionState() {
        if model.ignoredPhotosIsSelecting {
            selectBarButton.title = "Done"
        } else {
            selectBarButton.title = "Select"
            model.selectedPhotos = []
        }

        for sectionIndex in model.sections.indices {
            let section = model.sections[sectionIndex]
            for photoIndex in section.photos.indices {
                let indexPath = IndexPath(item: photoIndex, section: sectionIndex)
                if let cell = collectionView.cellForItem(at: indexPath) as? PhotosCollectionCell {
                    if model.ignoredPhotosIsSelecting {
                        cell.selectOverlayIconView.setState(.hidden)
                        UIView.animate(withDuration: ListsCellConstants.editAnimationDuration) {
                            cell.selectOverlayView.alpha = 1
                        }
                    } else {
                        UIView.animate(withDuration: ListsCellConstants.editAnimationDuration) {
                            cell.selectOverlayView.backgroundColor = .clear
                            cell.selectOverlayView.alpha = 0
                        }
                    }
                }
            }
        }
    }
}

