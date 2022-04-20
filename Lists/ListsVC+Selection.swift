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
        searchViewModel.dismissKeyboard?()
        selectBarButton.title = "Done"
        selectBarButton.accessibilityLabel = "Done"
        selectBarButton.accessibilityHint = "Stop selecting lists"
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = true
        toolbarViewModel.toolbar = AnyView(toolbarView)
        updateCollectionViewSelectionState()
    }

    func resetSelectingState() {
        model.isSelecting = false
        selectBarButton.title = "Select"
        selectBarButton.accessibilityLabel = "Select"
        selectBarButton.accessibilityHint = "Select lists"
        toolbarViewModel.toolbar = nil
        model.selectedLists = []
        updateCollectionViewSelectionState()
    }

    func listSelected(at indexPath: IndexPath) {
        guard let displayedList = model.displayedLists[safe: indexPath.item] else { return }
        if !model.selectedLists.contains(displayedList.list) {
            model.selectedLists.append(displayedList.list)

            if let cell = collectionView.cellForItem(at: indexPath) as? ListsContentCell {
                cell.view.configureSelection(selected: true, modelSelecting: model.isSelecting)
            }
        }
    }

    func listDeselected(at indexPath: IndexPath) {
        guard let displayedList = model.displayedLists[safe: indexPath.item] else { return }
        if model.selectedLists.contains(displayedList.list) {
            model.selectedLists = model.selectedLists.filter { $0 != displayedList.list }

            if let cell = collectionView.cellForItem(at: indexPath) as? ListsContentCell {
                cell.view.configureSelection(selected: false, modelSelecting: model.isSelecting)
            }
        }
    }

    func updateCollectionViewSelectionState() {
        for index in model.displayedLists.indices {
            if let cell = collectionView.cellForItem(at: index.indexPath) as? ListsContentCell {
                if model.isSelecting {
                    cell.view.isUserInteractionEnabled = false
                    cell.view.headerSelectionIconView.alpha = 0
                    UIView.animate(withDuration: ListsCellConstants.editAnimationDuration) {
                        cell.view.headerSelectionIconView.isHidden = false
                        cell.view.headerStackView.layoutIfNeeded()
                        cell.view.headerSelectionIconView.alpha = 1
                    }
                } else {
                    cell.view.isUserInteractionEnabled = true
                    cell.view.headerSelectionIconView.alpha = 1
                    UIView.animate(withDuration: ListsCellConstants.editAnimationDuration) {
                        cell.view.headerSelectionIconView.isHidden = true
                        cell.view.headerStackView.layoutIfNeeded()
                        cell.view.headerSelectionIconView.alpha = 0
                    } completion: { _ in
                        cell.view.headerSelectionIconView.setState(.empty)
                    }
                }
            }

            if !model.isSelecting {
                collectionView.deselectItem(at: index.indexPath, animated: false)
            }
        }
    }
}
