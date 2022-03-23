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
                        cell.selectOverlayIconView.setState(.hidden)
                        UIView.animate(withDuration: ListsCellConstants.editAnimationDuration) {
                            cell.selectOverlayView.alpha = 1
                            cell.selectOverlayIconView.alpha = 1
                        }
                    } else {
                        UIView.animate(withDuration: ListsCellConstants.editAnimationDuration) {
                            cell.selectOverlayView.alpha = 0
                            cell.selectOverlayIconView.alpha = 0
                        }
                    }
                }
            }
        }
    }
}
