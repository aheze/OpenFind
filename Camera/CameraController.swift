//
//  Camera.swift
//  Camera
//
//  Created by Zheng on 11/18/21.
//

import UIKit

class CameraController {
    
    var model: CameraViewModel
    var realmModel: RealmModel
    var viewController: CameraViewController
    
    init(model: CameraViewModel, realmModel: RealmModel) {
        self.model = model
        self.realmModel = realmModel
    
        let storyboard = UIStoryboard(name: "CameraContent", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "CameraViewController") { coder in
            CameraViewController(
                coder: coder,
                model: model,
                realmModel: realmModel
            )
        }
        
        self.viewController = viewController
        viewController.loadViewIfNeeded() /// needed to initialize outlets
    }
}
