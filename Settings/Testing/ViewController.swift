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
            
            Bridge.presentTopOfTheList = {}
            Bridge.presentRequiresSoftwareUpdate = { versionString in }
            Bridge.presentWhatsNew = {}
            Bridge.presentLicenses = {}
            Bridge.presentGeneralTutorial = {}
            Bridge.presentPhotosTutorial = {}
            Bridge.presentListsTutorial = {}
            Bridge.presentListsBuilderTutorial = {}
            Bridge.presentShareScreen = {}
            
            let vc = SettingsViewController()
            self.present(vc, animated: true)
        }
    }


}

