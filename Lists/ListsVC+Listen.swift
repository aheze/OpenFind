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
        listenToDefaults()

        model.deleteSelected = { [weak self] in
            guard let self = self else { return }
            self.deleteSelectedLists()
        }
        model.shareSelected = { [weak self] in
            guard let self = self else { return }

            let lists = self.model.selectedLists
            let urls = lists.compactMap { $0.getURL() }
            let dataSource = ListsSharingDataSource(lists: lists)
            self.presentShareSheet(items: urls + [dataSource], applicationActivities: nil)
            self.resetSelectingState()
        }

        model.addNewList = { [weak self] in
            guard let self = self else { return }
            self.addNewList()
        }

        searchViewModel.fieldsChanged = { [weak self] textChanged in
            guard let self = self else { return }
            guard textChanged else { return }
            let search = self.searchViewModel.text
            self.find(text: search)

            if self.searchViewModel.isEmpty {
                self.hideCancelNavigationBar()
            } else if self.navigationItem.leftBarButtonItem == nil {
                self.showCancelNavigationBar()
            }
        }
    }
}
