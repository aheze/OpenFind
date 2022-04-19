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
        if model.isSelecting {
            startSelecting()
        } else {
            resetSelectingState()
        }
    }

    func startSelecting() {
        model.updateAllowed = false
        searchViewModel.dismissKeyboard?()
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = true
        resultsCollectionView.allowsSelection = true
        resultsCollectionView.allowsMultipleSelection = true
        selectBarButton?.title = "Done"
        toolbarViewModel.toolbar = AnyView(selectionToolbar)
        showFiltersView(false, animate: true)
        if model.resultsState != nil {
            updateResultsCollectionViewSelectionState()
        } else {
            updateCollectionViewSelectionState()
        }
    }

    /// reset the state after finding from selected photos or pressing done
    /// also called in `willBecomeInactive`, so check `model.loaded`
    func resetSelectingState() {
        guard model.loaded else { return }
        
        model.updateAllowed = true
        model.isSelecting = false
        collectionView.allowsSelection = false
        collectionView.allowsMultipleSelection = false
        resultsCollectionView.allowsSelection = false
        resultsCollectionView.allowsMultipleSelection = false
        selectBarButton?.title = "Select"
        toolbarViewModel.toolbar = nil
        showFiltersView(true, animate: true)
        model.selectedPhotos = []
        model.ignoredPhotosSelectedPhotos = []
        if model.resultsState != nil {
            updateResultsCollectionViewSelectionState()
        } else {
            updateCollectionViewSelectionState()
        }
    }

    func photoSelected(at indexPath: IndexPath) {
        guard let photo = model.displayedSections[safe: indexPath.section]?.photos[safe: indexPath.item] else { return }
        if !model.selectedPhotos.contains(photo) {
            model.selectedPhotos.append(photo)

            if let cell = collectionView.cellForItem(at: indexPath) as? PhotosCollectionCell {
                configureCellSelection(cell: cell, selected: true)
            }
        }
    }

    func photoDeselected(at indexPath: IndexPath) {
        guard let photo = model.displayedSections[safe: indexPath.section]?.photos[safe: indexPath.item] else { return }
        if model.selectedPhotos.contains(photo) {
            model.selectedPhotos = model.selectedPhotos.filter { $0 != photo }

            if let cell = collectionView.cellForItem(at: indexPath) as? PhotosCollectionCell {
                configureCellSelection(cell: cell, selected: false)
            }
        }
    }

    func configureCellSelection(cell: PhotosCollectionCell, selected: Bool) {
        cell.view.selectOverlayIconView.setState(selected ? .selected : .hidden)
        cell.view.selectOverlayView.backgroundColor = selected ? PhotosCellConstants.selectedBackgroundColor : .clear
    }

    func updateCollectionViewSelectionState() {
        for sectionIndex in model.displayedSections.indices {
            let section = model.displayedSections[sectionIndex]
            for photoIndex in section.photos.indices {
                let indexPath = IndexPath(item: photoIndex, section: sectionIndex)
                if let cell = collectionView.cellForItem(at: indexPath) as? PhotosCollectionCell {
                    if model.isSelecting {
                        cell.buttonView.isUserInteractionEnabled = false
                        cell.view.selectOverlayIconView.setState(.hidden)
                        UIView.animate(withDuration: ListsCellConstants.editAnimationDuration) {
                            cell.view.selectOverlayView.alpha = 1
                        }
                    } else {
                        cell.buttonView.isUserInteractionEnabled = true
                        UIView.animate(withDuration: ListsCellConstants.editAnimationDuration) {
                            cell.view.selectOverlayView.backgroundColor = .clear
                            cell.view.selectOverlayView.alpha = 0
                        }
                    }
                }

                if !model.isSelecting {
                    collectionView.deselectItem(at: indexPath, animated: false)
                }
            }
        }
    }
}
