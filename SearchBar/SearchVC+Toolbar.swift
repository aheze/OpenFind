//
//  SearchVC+Toolbar.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/2/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension SearchViewController {
    func listenToToolbar() {
        keyboardToolbarViewModel.listSelected = { [weak self] list in
            guard let self = self else { return }
            if let currentIndex = self.collectionViewModel.focusedCellIndex {
                guard let currentField = self.searchViewModel.fields[safe: currentIndex] else { return }
                let originalText = currentField.value.getOriginalText()

                /// deselect list
                if case .list(let existingList, _) = currentField.value, existingList.id == list.id {
                    let field = Field(
                        configuration: self.searchViewModel.configuration,
                        value: .word(.init(string: originalText))
                    )
                    self.searchViewModel.updateField(at: currentIndex, with: field, notify: true)
                } else {
                    /// select list
                    let field = Field(
                        configuration: self.searchViewModel.configuration,
                        value: .list(list, originalText: originalText)
                    )
                    self.searchViewModel.updateField(at: currentIndex, with: field, notify: true)
                }

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
