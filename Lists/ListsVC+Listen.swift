//
//  ListsVC+Listen.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/30/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension ListsViewController {
    func listen() {
        listenToListsChange()
        listenToDefaults()
        listenToKeyboard()

        model.deleteSelected = { [weak self] in
            guard let self = self else { return }
            self.deleteSelectedLists()
        }
        model.shareSelected = { [weak self] in
            guard let self = self else { return }

            let lists = self.model.selectedLists
            let urls = lists.compactMap { $0.getURL() }
            let dataSource = ListsSharingDataSource(lists: lists)

            let sourceRect = CGRect(
                x: 0,
                y: self.view.bounds.height - self.tabViewModel.tabBarAttributes.backgroundHeight,
                width: 50,
                height: 50
            )

            self.presentShareSheet(
                items: urls + [dataSource],
                applicationActivities: nil,
                sourceRect: sourceRect
            )
            self.resetSelectingState()
        }

        model.addNewList = { [weak self] in
            guard let self = self else { return }
            self.addNewList()
        }

        searchViewModel.fieldsChanged = { [weak self] textChanged in
            guard let self = self else { return }
            guard textChanged else { return }

            if self.searchViewModel.isEmpty {
                self.model.isFinding = false
                self.hideCancelNavigationBar()
            } else if !self.model.isFinding {
                self.model.isFinding = true
                self.resetSelectingState()
                self.showCancelNavigationBar()
            }

            let search = self.searchViewModel.text
            self.find(text: search)
        }
    }
}
