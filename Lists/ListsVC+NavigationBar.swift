//
//  ListsViewController+NavigationBar.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/8/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension ListsViewController {
    func setupNavigationBar() {
        let selectButton = UIBarButtonItem(
            title: "Select",
            style: .plain,
            target: self,
            action: #selector(selectPressed)
        )

        let addButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addListPressed)
        )
        
        selectBarButton = selectButton
        navigationItem.rightBarButtonItems = [addButton, selectButton]
    }
    
    func showCancelNavigationBar() {
        let cancelButton = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelPressed)
        )
        navigationItem.leftBarButtonItem = cancelButton
    }

    func hideCancelNavigationBar() {
        navigationItem.leftBarButtonItem = nil
    }
    
    @objc func cancelPressed() {
        resetSelectingState()
        searchViewModel.updateFields(fields: searchViewModel.getDefaultFields(realmModel: realmModel), notify: true)
        model.updateSearchCollectionView?()
    }

    @objc func selectPressed() {
        /// inside ListsVC+Selection
        toggleSelect()
    }

    @objc func addListPressed() {
        /// inside ListsVC+Add
        addNewList()
    }
    
    func updateViewsEnabled() {
        selectBarButton?.isEnabled = !model.displayedLists.isEmpty
    }
}
