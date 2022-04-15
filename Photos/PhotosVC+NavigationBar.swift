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
        selectBarButton = selectButton
        
        let scanningButton = UIBarButtonItem.customButton(customView: scanningIconController.view, length: 34)
        scanningBarButton = scanningButton
        
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
    
    func updateViewsEnabled() {
        if let resultsState = model.resultsState {
            model.photosEditable = !resultsState.displayedFindPhotos.isEmpty
        } else {
            model.photosEditable = !model.displayedSections.isEmpty
        }
        selectBarButton?.isEnabled = model.photosEditable
    }

    func hideCancelNavigationBar() {
        navigationItem.leftBarButtonItem = nil
    }
    
    /// hide when enter results
    func showScanningButton(_ show: Bool) {
        guard let scanningBarButton = scanningBarButton, let selectBarButton = selectBarButton else { return }
        if show {
            navigationItem.rightBarButtonItems = [scanningBarButton, selectBarButton]
        } else {
            navigationItem.rightBarButtonItems = [selectBarButton]
        }
    }
    
    @objc func cancelPressed() {
        hideCancelNavigationBar()
        searchViewModel.updateFields(fields: searchViewModel.getDefaultFields(realmModel: realmModel), notify: true)
        model.updateSearchCollectionView?()
    }

    @objc func selectPressed() {
        toggleSelect()
    }
}
