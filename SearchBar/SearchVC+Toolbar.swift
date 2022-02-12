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

    func listenToToolbar() {
        keyboardToolbarViewModel.listSelected = { [weak self] list in
            guard let self = self else { return }
            if let currentIndex = self.collectionViewModel.focusedCellIndex {
                self.searchViewModel.fields[currentIndex] = Field(
                    configuration: self.searchViewModel.configuration,
                    value: .list(list)
                )

                if let cell = self.searchCollectionView.cellForItem(at: currentIndex.indexPath) as? SearchFieldCell {
                    self.configureCell(cell, for: currentIndex)
                }
            }
        }
    }

    @objc func listsUpdated(notification: Notification) {
        keyboardToolbarViewModel.reloadDisplayedLists()
    }
}

extension SearchViewController {
    func listenToKeyboard() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc func keyboardWillShow(_ notification: Notification) {

        if
            let currentIndex = collectionViewModel.focusedCellIndex,
            let cell = searchCollectionView.cellForItem(at: currentIndex.indexPath) as? SearchFieldCell
        {
            if toolbarViewController.reloadFrame(keyboardShown: true) {
                cell.textField.reloadInputViews()
            }
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        if
            let currentIndex = collectionViewModel.focusedCellIndex,
            let cell = searchCollectionView.cellForItem(at: currentIndex.indexPath) as? SearchFieldCell
        {
            if toolbarViewController.reloadFrame(keyboardShown: false) {
                cell.textField.reloadInputViews()
            }
        }
    }
}
