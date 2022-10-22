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
        collectionView.allowsMultipleSelection = true
        resultsCollectionView.allowsMultipleSelection = true
        selectBarButton?.title = "Done"
        selectBarButton?.accessibilityLabel = "Done"
        selectBarButton?.accessibilityHint = "Stop selecting photos"
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
        collectionView.allowsMultipleSelection = false
        resultsCollectionView.allowsMultipleSelection = false
        selectBarButton?.title = "Select"
        selectBarButton?.accessibilityLabel = "Select"
        selectBarButton?.accessibilityHint = "Select photos"
        toolbarViewModel.toolbar = nil
        showFiltersView(true, animate: true)
        model.selectedPhotos = []

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

            if let cell = collectionView.cellForItem(at: indexPath) as? PhotosCell {
                cell.model.selected = true
                cell.accessibilityTraits = .selected
            }
        }
    }

    func photoDeselected(at indexPath: IndexPath) {
        guard let photo = model.displayedSections[safe: indexPath.section]?.photos[safe: indexPath.item] else { return }
        if model.selectedPhotos.contains(photo) {
            model.selectedPhotos = model.selectedPhotos.filter { $0 != photo }

            if let cell = collectionView.cellForItem(at: indexPath) as? PhotosCell {
                cell.model.selected = false
                cell.accessibilityTraits = .none
            }
        }
    }

    func updateCollectionViewSelectionState() {
        for sectionIndex in model.displayedSections.indices {
            let section = model.displayedSections[sectionIndex]
            for photoIndex in section.photos.indices {
                let indexPath = IndexPath(item: photoIndex, section: sectionIndex)
                if let cell = collectionView.cellForItem(at: indexPath) as? PhotosCell {
                    cell.model.showSelectionOverlay = model.isSelecting
                    cell.model.selected = false
                }

                if !model.isSelecting {
                    collectionView.deselectItem(at: indexPath, animated: false)
                }
            }
        }
    }
}
