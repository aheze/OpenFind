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

        cameraViewModel.settingsPressed = { [weak self] in
            guard let self = self else { return }
            self.present(self.settingsController.viewController, animated: true)
            self.camera.viewController.stopRunning()
        }
        SettingsData.showScanningOptions = { [weak self] in
            guard let self = self else { return }
            self.settingsController.viewController.present(self.photos.viewController.scanningNavigationViewController, animated: true)
        }
        SettingsData.exportAllLists = { [weak self] in
            guard let self = self else { return }
            self.exportAllLists()
        }
        SettingsData.deleteAllPhotoMetadata = { [weak self] in
            guard let self = self else { return }
            self.deleteAllPhotoMetadata()
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

    func deleteAllPhotoMetadata() {
        let alert = UIAlertController(title: "Delete All Scanned Data?", message: "Are you sure you want to delete all scanned data? This can't be undone.", preferredStyle: .actionSheet)
        alert.addAction(
            UIAlertAction(title: "Delete", style: .destructive) { [weak self] action in
                guard let self = self else { return }
                Task {
                    await self.photosViewModel.deleteAllMetadata()
                }
            }
        )
        alert.addAction(
            UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        )
        self.settingsController.viewController.present(alert, animated: true, completion: nil)
    }
}
