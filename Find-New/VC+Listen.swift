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

        self.settingsController.viewController.presentationController?.delegate = self
        self.settingsController.model.dismissed = { [weak self] in
            guard let self = self else { return }
            self.camera.viewController.willBecomeActive()
        }
    }

    func exportAllLists() {
        let displayedLists = lists.model.displayedLists.map { $0.list }
        let urls = displayedLists.compactMap { $0.getURL() }
        let dataSource = ListsSharingDataSource(lists: displayedLists)
        self.settingsController.viewController.presentShareSheet(items: urls + [dataSource])
    }

    func deleteAllPhotoMetadata() {
        let alert = UIAlertController(title: "Delete All Scanned Data?", message: "Are you sure you want to delete all scanned data? This can't be undone.", preferredStyle: .actionSheet)
        alert.addAction(
            UIAlertAction(title: "Delete", style: .destructive) { [weak self] action in
                guard let self = self else { return }
                self.photosViewModel.deleteAllMetadata()
            }
        )
        alert.addAction(
            UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        )
        self.settingsController.viewController.present(alert, animated: true, completion: nil)
    }
}

extension ViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        camera.viewController.willBecomeActive()
    }
}
