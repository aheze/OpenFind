//
//  PhotosVC+Setup.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/14/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Combine
import Photos
import SwiftUI

/**
 Pin the collection view, listen to the model, set up the navigation bar
 Show permissions view if needed
 */
extension PhotosViewController {
    func setup() {
        collectionView.register(PhotosCell.self, forCellWithReuseIdentifier: "PhotosCell")
        resultsCollectionView.register(PhotosCellResults.self, forCellWithReuseIdentifier: "PhotosCellResults")
        setupCollectionView(collectionView, with: flowLayout)
        setupCollectionView(resultsCollectionView, with: resultsFlowLayout)
        showResults(false)
        resultsCollectionView.backgroundColor = .secondarySystemBackground

        /// SwiftUI container
        contentContainer.backgroundColor = .clear
        contentContainer.isUserInteractionEnabled = false
        setupNavigationBar()

        /// filters
        setupFiltersView()

        listen()

        checkPermissions()
    }

    func checkPermissions() {
        switch photosPermissionsViewModel.currentStatus {
        case .notDetermined:
            showPermissionsView()
        case .restricted:
            showPermissionsView()
        case .denied:
            showPermissionsView()
        case .authorized:
            load()
        case .limited:
            load()
        @unknown default:
            fatalError()
        }
    }

    func load() {
        setupEmptyContent()
        startObservingChanges()
        model.load()
        searchViewModel.enabled = true
        slidesSearchViewModel.enabled = true
    }

    func finishedLoading() {
        /// show views again
        UIView.animate(duration: 0.3, dampingFraction: 0.8) {
            self.collectionView.alpha = 1
        }

        showFiltersView(true, animate: true) /// already has an animation

        model.displayedSections = model.allSections
        update(animate: false)
        
        /// user entered text before photos were loaded, so find now
        if !searchViewModel.isEmpty {
            find(context: .findingAfterTextChange(firstTimeShowingResults: true))
        }
    }

    func showPermissionsView() {
        collectionView.alpha = 0
        showFiltersView(false, animate: false)
        selectBarButton?.isEnabled = false
        searchViewModel.enabled = false
        slidesSearchViewModel.enabled = false

        let permissionsView = PhotosPermissionsView(model: photosPermissionsViewModel)
        let hostingController = UIHostingController(rootView: permissionsView)
        hostingController.view.backgroundColor = .clear
        addChildViewController(hostingController, in: view)
        view.bringSubviewToFront(hostingController.view)
        photosPermissionsViewModel.$currentStatus
            .dropFirst()
            .sink { [weak self] status in
                if status.isGranted() {
                    guard let self = self else { return }
                    self.load()

                    UIView.animate(withDuration: 0.5) { [weak hostingController] in
                        hostingController?.view.alpha = 0
                    } completion: { [weak hostingController] _ in
                        hostingController?.view.removeFromSuperview()
                    }
                }
            }
            .store(in: &realmModel.cancellables)
    }
}

extension PhotosViewController {
    /// `addSubview` is also called inside `PhotosVC+Results`
    func setupCollectionView(_ collectionView: UICollectionView, with layout: UICollectionViewFlowLayout) {
        collectionViewContainer.addSubview(collectionView)
        collectionView.pinEdgesToSuperview()

        collectionView.delegate = self
        collectionView.delaysContentTouches = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.keyboardDismissMode = .interactive
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset.top = searchViewModel.getTotalHeight()
        collectionView.contentInset.bottom = PhotosConstants.bottomPadding + SliderConstants.height /// padding for the slider
        collectionView.verticalScrollIndicatorInsets.top = searchViewModel.getTotalHeight() + SearchNavigationConstants.scrollIndicatorTopPadding
        collectionView.verticalScrollIndicatorInsets.bottom = PhotosConstants.bottomPadding + SliderConstants.height /// padding for the slider
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.collectionViewLayout = layout
    }
}
