//
//  ViewController.swift
//  Settings
//
//  Created by Zheng on 11/18/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            
            Settings.Bridge.presentTopOfTheList = {}
            Settings.Bridge.presentRequiresSoftwareUpdate = { versionString in }
            Settings.Bridge.presentWhatsNew = {}
            Settings.Bridge.presentLicenses = {}
            Settings.Bridge.presentGeneralTutorial = {}
            Settings.Bridge.presentPhotosTutorial = {}
            Settings.Bridge.presentListsTutorial = {}
            Settings.Bridge.presentListsBuilderTutorial = {}
            Settings.Bridge.presentShareScreen = {}
            
            let vc = SettingsViewController()
            self.present(vc, animated: true)
        }
    }


}

