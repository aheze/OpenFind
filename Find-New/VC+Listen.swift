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
        ViewControllerCallback.getListDetailController = { [weak self] list in
            guard let self = self else { return nil }
            let viewController = self.lists.viewController.getDetailViewController(list: list, focusFirstWord: false, addDismissButton: true)
            return viewController
        }
        tabViewModel.tappedTabAgain = { [weak self] tab in
            guard let self = self else { return }

            /// should just be photos or lists, camera is already handled
            switch tab {
            case .photos:
                if self.photosViewModel.resultsState != nil {
                    let topOffset = self.photos.viewController.view.safeAreaInsets.top + self.photos.viewController.searchViewModel.getTotalHeight()
                    self.photos.viewController.resultsCollectionView.setContentOffset(CGPoint(x: 0, y: -topOffset), animated: true)
                } else {
                    let topOffset = self.photos.viewController.view.safeAreaInsets.top + self.photos.viewController.searchViewModel.getTotalHeight()
                    self.photos.viewController.collectionView.setContentOffset(CGPoint(x: 0, y: -topOffset), animated: true)
                }
            case .lists:

                /// can't check `detailsViewController` because it's not released on dismiss
                if self.lists.viewController.navigationController.map({ $0.viewControllers.count > 1 }) ?? false {
                    self.lists.viewController.navigationController?.popViewController(animated: true)
                } else {
                    let topOffset = self.lists.viewController.view.safeAreaInsets.top + self.lists.viewController.searchViewModel.getTotalHeight()
                    self.lists.viewController.collectionView.setContentOffset(CGPoint(x: 0, y: -topOffset), animated: true)
                }
            default: break
            }
        }

        cameraViewModel.settingsPressed = { [weak self] in
            guard let self = self else { return }
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
        SettingsData.deleteAllScannedData = { [weak self] in
            guard let self = self else { return }
            self.deleteAllScannedData()
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
        self.settingsController.viewController.presentShareSheet(items: urls + [dataSource], applicationActivities: nil)
    }

    func deleteAllScannedData() {
        let alert = UIAlertController(title: "Delete All Scanned Data?", message: "Are you sure you want to delete all scanned data? This can't be undone.", preferredStyle: .actionSheet)
        alert.addAction(
            UIAlertAction(title: "Delete", style: .destructive) { [weak self] action in
                guard let self = self else { return }
                Task {
                    await self.photosViewModel.deleteAllScannedData()
                }
            }
        )
        alert.addAction(
            UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        )
        self.settingsController.viewController.present(alert, animated: true, completion: nil)
    }
}
