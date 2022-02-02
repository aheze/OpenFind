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
        listenToToolbar()
    }
    
    func listenToToolbar() {
        keyboardToolbarViewModel.listSelected = { [weak self] list in
            guard let self = self else { return }
            if let currentIndex = self.searchCollectionViewFlowLayout.focusedCellIndex {
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
