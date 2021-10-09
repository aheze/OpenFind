//
//  ViewController.swift
//  SettingsTesting
//
//  Created by Zheng on 10/9/21.
//

import UIKit
import Settings

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            
            Settings.Bridge.presentTopOfTheList = {}
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

