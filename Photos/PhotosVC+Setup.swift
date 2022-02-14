//
//  PhotosVC+Setup.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/14/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Photos
import SwiftUI

extension PhotosViewController {
    func setup() {
        setupCollectionView()
        checkPermissions()
    }

    func checkPermissions() {
        switch permissionsViewModel.currentStatus {
        case .notDetermined:
            showPermissionsView()
        case .restricted:
            showPermissionsView()
        case .denied:
            showPermissionsView()
        case .authorized:
            showCollectionView()
        case .limited:
            showCollectionView()
        @unknown default:
            fatalError()
        }
    }

    func showPermissionsView() {
        collectionView.alpha = 0
        let permissionsView = PhotosPermissionsView(model: permissionsViewModel)
        let hostingController = UIHostingController(rootView: permissionsView)
        addChildViewController(hostingController, in: view)
        view.bringSubviewToFront(hostingController.view)
        permissionsViewModel.permissionsGranted = { [weak self] in
            guard let self = self else { return }
        }
    }

    func showCollectionView() {
        UIView.animate(withDuration: 0.5) {
            self.collectionView.alpha = 1
        }
    }
}

extension PhotosViewController {
    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsSelection = false
        collectionView.delaysContentTouches = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.keyboardDismissMode = .interactive
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset.top = searchViewModel.getTotalHeight()
        collectionView.verticalScrollIndicatorInsets.top = searchViewModel.getTotalHeight() + SearchNavigationConstants.scrollIndicatorTopPadding
    }
}
