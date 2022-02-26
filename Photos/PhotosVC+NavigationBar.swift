//
//  PhotosVC+NavigationBar.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/25/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

extension PhotosViewController {
    func setupNavigationBar() {
        let selectButton = UIBarButtonItem(
            title: "Select",
            style: .plain,
            target: self,
            action: #selector(selectPressed)
        )
        self.selectBarButton = selectButton
        
        let scanningButton = UIBarButtonItem.customButton(customView: scanningIconController.view, length: 34)
        navigationItem.rightBarButtonItems = [scanningButton, selectButton]
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
        hideCancelNavigationBar()
        searchViewModel.fields = SearchViewModel.defaultFields
        model.updateSearchCollectionView?()
    }

    
    @objc func selectPressed() {
//        toggleSelect()
    }
}
