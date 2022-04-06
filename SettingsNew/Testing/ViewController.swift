//
//  ViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/30/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    lazy var realmModel = RealmModel()
    lazy var settingsController = SettingsController(realmModel: realmModel)

    override func viewDidLoad() {
        super.viewDidLoad()

        _ = settingsController
        addChildViewController(settingsController.viewController, in: view)

        SettingsData.showScanningOptions = { [weak self] in
            guard let self = self else { return }
            print("Show scanning options")
        }
        SettingsData.exportAllLists = { [weak self] in
            guard let self = self else { return }
            print("Export all lists")
        }
    }
}
