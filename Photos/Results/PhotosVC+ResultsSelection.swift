//
//  PhotosVC+ResultsSelection.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/23/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension PhotosViewController {
    func photoResultsSelected(at indexPath: IndexPath) {
        guard let resultsState = model.resultsState, let findPhoto = resultsState.displayedFindPhotos[safe: indexPath.item] else { return }

        if !model.selectedPhotos.contains(findPhoto.photo) {
            model.selectedPhotos.append(findPhoto.photo)

            if let cell = resultsCollectionView.cellForItem(at: indexPath) as? PhotosResultsCell {
                configureResultsCellSelection(cell: cell, findPhoto: findPhoto, selected: true)
            }
        }
    }

    func photoResultsDeselected(at indexPath: IndexPath) {
        guard let resultsState = model.resultsState, let findPhoto = resultsState.displayedFindPhotos[safe: indexPath.item] else { return }

        if model.selectedPhotos.contains(findPhoto.photo) {
            model.selectedPhotos = model.selectedPhotos.filter { $0 != findPhoto.photo }

            if let cell = resultsCollectionView.cellForItem(at: indexPath) as? PhotosResultsCell {
                configureResultsCellSelection(cell: cell, findPhoto: findPhoto, selected: false)
            }
        }
    }

    func configureResultsCellSelection(cell: PhotosResultsCell, findPhoto: FindPhoto, selected: Bool) {
        cell.view.selectOverlayIconView.setState(selected ? .selected : .hidden)
        cell.view.selectOverlayView.backgroundColor = selected ? PhotosCellConstants.selectedBackgroundColor : .clear
        cell.buttonView.isUserInteractionEnabled = !model.isSelecting
        cell.view.selectOverlayIconView.setState(selected ? .selected : .hidden)
        cell.view.selectOverlayView.backgroundColor = selected ? PhotosCellConstants.selectedBackgroundColor : .clear

        
        if selected {
            cell.accessibilityTraits = .selected
        } else {
            cell.accessibilityTraits = .none
        }
    }

    func updateResultsCollectionViewSelectionState() {
        guard let resultsState = model.resultsState else { return }
        for index in resultsState.displayedFindPhotos.indices {
            let indexPath = index.indexPath
            if let cell = resultsCollectionView.cellForItem(at: indexPath) as? PhotosResultsCell {
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
                resultsCollectionView.deselectItem(at: indexPath, animated: false)
            }
        }
    }
}
