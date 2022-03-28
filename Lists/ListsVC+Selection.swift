//
//  ListsVC+Selection.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/29/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

extension ListsViewController {
    func toggleSelect() {
        model.isSelecting.toggle()
        if model.isSelecting {
            startSelecting()
        } else {
            resetSelectingState()
        }
    }
    
    func startSelecting() {
        selectBarButton.title = "Done"
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = true
        toolbarViewModel.toolbar = AnyView(toolbarView)
        updateCollectionViewSelectionState()
    }

    func resetSelectingState() {
        model.isSelecting = false
        selectBarButton.title = "Select"
        toolbarViewModel.toolbar = nil
        model.selectedLists = []
        updateCollectionViewSelectionState()
    }

    func listSelected(at indexPath: IndexPath) {
        guard let displayedList = model.displayedLists[safe: indexPath.item] else { return }
        if !model.selectedLists.contains(displayedList.list) {
            model.selectedLists.append(displayedList.list)

            if let cell = collectionView.cellForItem(at: indexPath) as? ListsContentCell {
                configureCellSelection(cell: cell, selected: true)
            }
        }
    }

    func listDeselected(at indexPath: IndexPath) {
        guard let displayedList = model.displayedLists[safe: indexPath.item] else { return }
        if model.selectedLists.contains(displayedList.list) {
            model.selectedLists = model.selectedLists.filter { $0 != displayedList.list }

            if let cell = collectionView.cellForItem(at: indexPath) as? ListsContentCell {
                configureCellSelection(cell: cell, selected: false)
            }
        }
    }

    func updateCollectionViewSelectionState() {
        for index in model.displayedLists.indices {
            if let cell = collectionView.cellForItem(at: index.indexPath) as? ListsContentCell {
                if model.isSelecting {
                    cell.contentView.isUserInteractionEnabled = false
                    cell.headerSelectionIconView.alpha = 0
                    UIView.animate(withDuration: ListsCellConstants.editAnimationDuration) {
                        cell.headerSelectionIconView.isHidden = false
                        cell.headerStackView.layoutIfNeeded()
                        cell.headerSelectionIconView.alpha = 1
                    }
                } else {
                    cell.contentView.isUserInteractionEnabled = true
                    cell.headerSelectionIconView.alpha = 1
                    UIView.animate(withDuration: ListsCellConstants.editAnimationDuration) {
                        cell.headerSelectionIconView.isHidden = true
                        cell.headerStackView.layoutIfNeeded()
                        cell.headerSelectionIconView.alpha = 0
                    } completion: { _ in
                        cell.headerSelectionIconView.setState(.empty)
                    }
                }
            }

            if !model.isSelecting {
                collectionView.deselectItem(at: index.indexPath, animated: false)
            }
        }
    }
}
