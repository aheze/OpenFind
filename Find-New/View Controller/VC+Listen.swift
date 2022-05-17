//
//  VC+Listen.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/6/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension ViewController {
    func listen() {
        listenToDefaults()

        SettingsData.getHelpCenter = { [weak self] in
            guard let self = self else { return nil }
            return self.settingsController.viewController.getSupportDocs()
        }

        ViewControllerCallback.getListDetailController = { [weak self] toolbarViewModel, list in
            guard let self = self else { return nil }
            let viewController = self.lists.viewController.getDetailViewController(
                toolbarViewModel: toolbarViewModel,
                list: list,
                focusFirstWord: false,
                addDismissButton: true
            )
            return viewController
        }

        ViewControllerCallback.deleteAllScannedData = { [weak self] allPhotos in
            guard let self = self else { return }
            self.deleteAllScannedData(allPhotos: allPhotos)
        }

        tabViewModel.tappedTabAgain = { [weak self] tab in
            guard let self = self else { return }

            /// should just be photos or lists, camera is already handled
            switch tab {
            case .photos:
                if self.photosViewModel.resultsState != nil {
                    let topOffset = self.photos.viewController.view.safeAreaInsets.top + self.photos.viewController.searchViewModel.getTotalHeight()
                    let leftContentOffset = self.photos.viewController.resultsCollectionView.adjustedContentInset.left
                    self.photos.viewController.resultsCollectionView.setContentOffset(CGPoint(x: -leftContentOffset, y: -topOffset), animated: true)
                } else {
                    let topOffset = self.photos.viewController.view.safeAreaInsets.top + self.photos.viewController.searchViewModel.getTotalHeight()
                    let leftContentOffset = self.photos.viewController.collectionView.adjustedContentInset.left

                    self.photos.viewController.collectionView.setContentOffset(CGPoint(x: -leftContentOffset, y: -topOffset), animated: true)
                }
            case .lists:

                /// can't check `detailsViewController` because it's not released on dismiss
                if self.lists.viewController.navigationController.map({ $0.viewControllers.count > 1 }) ?? false {
                    self.lists.viewController.navigationController?.popViewController(animated: true)
                } else {
                    let topOffset = self.lists.viewController.view.safeAreaInsets.top + self.lists.viewController.searchViewModel.getTotalHeight()
                    let leftContentOffset = self.lists.viewController.collectionView.adjustedContentInset.left
                    self.lists.viewController.collectionView.setContentOffset(CGPoint(x: -leftContentOffset, y: -topOffset), animated: true)
                }
            default: break
            }
        }

        cameraViewModel.settingsPressed = { [weak self] in
            guard let self = self else { return }
            self.settingsController.viewController.presentationController?.delegate = self
            self.present(self.settingsController.viewController, animated: true)
            self.camera.viewController.stopRunning()
        }
        cameraViewModel.photoAdded = { [weak self] photo in
            guard let self = self else { return }
            self.photosViewModel.photosAddedFromCamera.append(photo)
        }

        SettingsData.showScanningOptions = { [weak self] in
            guard let self = self else { return }
            self.settingsController.viewController.present(self.photos.viewController.scanningNavigationViewController, animated: true)
        }
        SettingsData.exportAllLists = { [weak self] in
            guard let self = self else { return }
            self.exportAllLists()
        }

        self.settingsController.model.startedToDismiss = { [weak self] in
            guard let self = self else { return }

            self.camera.viewController.willBecomeActive()
        }
    }

    func exportAllLists() {
        let displayedLists = lists.model.displayedLists.map { $0.list }
        let urls = displayedLists.compactMap { $0.getURL() }
        let dataSource = ListsSharingDataSource(lists: displayedLists)

        let sourceRect = CGRect(
            x: self.settingsController.viewController.view.bounds.width / 2,
            y: 50,
            width: 1,
            height: 1
        )

        self.settingsController.viewController.presentShareSheet(
            items: urls + [dataSource],
            applicationActivities: nil,
            sourceRect: sourceRect
        )
    }

    func deleteAllScannedData(allPhotos: Bool) {
        Task {
            await self.photosViewModel.deleteAllScannedData(allPhotos: allPhotos)
        }
    }
}

extension ViewController: UIAdaptivePresentationControllerDelegate {
    /// for settings
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        settingsController.mainViewController.searchViewModel.dismissKeyboard?()
        camera.viewController.willBecomeActive()
    }
}
