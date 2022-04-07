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
            self.camera.viewController.didBecomeInactive()
        }
        SettingsData.showScanningOptions = { [weak self] in
            guard let self = self else { return }
            print("Show scanning options")
        }
        SettingsData.exportAllLists = { [weak self] in
            guard let self = self else { return }
            print("Export all lists")
        }

        self.settingsController.viewController.presentationController?.delegate = self
        self.settingsController.model.dismissed = { [weak self] in
            guard let self = self else { return }
            self.camera.viewController.willBecomeActive()
        }
    }
}

extension ViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        camera.viewController.willBecomeActive()
    }
}
