//
//  Camera.swift
//  Camera
//
//  Created by Zheng on 11/18/21.
//

import UIKit

class CameraController {
    var model: CameraViewModel
    var tabViewModel: TabViewModel
    var realmModel: RealmModel
    var viewController: CameraViewController
    var settingsController: SettingsController
    
    init(
        model: CameraViewModel,
        tabViewModel: TabViewModel,
        realmModel: RealmModel
    ) {
        self.model = model
        self.tabViewModel = tabViewModel
        self.realmModel = realmModel
    
        let storyboard = UIStoryboard(name: "CameraContent", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "CameraViewController") { coder in
            CameraViewController(
                coder: coder,
                model: model,
                tabViewModel: tabViewModel,
                realmModel: realmModel
            )
        }
        
        self.viewController = viewController
        viewController.loadViewIfNeeded() /// needed to initialize outlets
    
        let settingsController = SettingsController(realmModel: realmModel)
        self.settingsController = settingsController
    }
}
