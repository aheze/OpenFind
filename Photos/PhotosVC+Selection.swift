//
//  PhotosVC+Selection.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/22/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

extension PhotosViewController {
    func toggleSelect() {
        model.isSelecting.toggle()
        updateCollectionViewSelectionState()
    }

    func photoSelected(at indexPath: IndexPath) {
        guard let photo = model.sections[safe: indexPath.section]?.photos[safe: indexPath.item] else { return }
        if !model.selectedPhotos.contains(photo) {
            model.selectedPhotos.append(photo)

            if let cell = collectionView.cellForItem(at: indexPath) as? PhotosCollectionCell {
                configureCellSelection(cell: cell, selected: true)
            }
        }
    }

    func photoDeselected(at indexPath: IndexPath) {
        guard let photo = model.sections[safe: indexPath.section]?.photos[safe: indexPath.item] else { return }
        if model.selectedPhotos.contains(photo) {
            model.selectedPhotos = model.selectedPhotos.filter { $0 != photo }

            if let cell = collectionView.cellForItem(at: indexPath) as? PhotosCollectionCell {
                configureCellSelection(cell: cell, selected: false)
            }
        }
    }
    
    func configureCellSelection(cell: PhotosCollectionCell, selected: Bool) {
        cell.selectOverlayIconView.setState(selected ? .selected : .hidden)
        cell.selectOverlayView.backgroundColor = selected ? PhotosCellConstants.selectedBackgroundColor : .clear
    }

    func updateCollectionViewSelectionState() {
        if model.isSelecting {
            selectBarButton.title = "Done"
            toolbarViewModel.toolbar = AnyView(selectionToolbar)
        } else {
            selectBarButton.title = "Select"
            toolbarViewModel.toolbar = nil
            model.selectedPhotos = []
        }

        for sectionIndex in model.sections.indices {
            let section = model.sections[sectionIndex]
            for photoIndex in section.photos.indices {
                let indexPath = IndexPath(item: photoIndex, section: sectionIndex)
                if let cell = collectionView.cellForItem(at: indexPath) as? PhotosCollectionCell {
                    if model.isSelecting {
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
                    }
                }
            }
        }
    }
}
