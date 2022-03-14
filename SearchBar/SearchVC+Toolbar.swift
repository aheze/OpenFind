//
//  SearchVC+Toolbar.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/2/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension SearchViewController {
    func setupToolbar() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(listsUpdated),
            name: .listsUpdated,
            object: nil
        )
    }

    @objc func listsUpdated(notification: Notification) {
        keyboardToolbarViewModel.reloadDisplayedLists()
    }

    func listenToToolbar() {
        keyboardToolbarViewModel.listSelected = { [weak self] list in
            guard let self = self else { return }
            if let currentIndex = self.collectionViewModel.focusedCellIndex {
                let field = Field(
                    configuration: self.searchViewModel.configuration,
                    value: .list(list)
                )
                self.searchViewModel.updateField(at: currentIndex, with: field, notify: true)

                if let cell = self.searchCollectionView.cellForItem(at: currentIndex.indexPath) as? SearchFieldCell {
                    self.configureCell(cell, for: currentIndex)
                }
            }
        }
    }

    /// Refresh the toolbar's height
    func reloadToolbarFrame() {
        if
            let currentIndex = collectionViewModel.focusedCellIndex,
            let cell = searchCollectionView.cellForItem(at: currentIndex.indexPath) as? SearchFieldCell
        {
            if toolbarViewController.reloadFrame() {
                cell.textField.reloadInputViews()
            }
        }
    }
}
