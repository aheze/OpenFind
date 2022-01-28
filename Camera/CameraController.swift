//
//  Camera.swift
//  Camera
//
//  Created by Zheng on 11/18/21.
//

import UIKit

class CameraController {
    var viewController: CameraViewController
    var cameraViewModel: CameraViewModel
    var realmModel: RealmModel
    
    init(cameraViewModel: CameraViewModel, realmModel: RealmModel) {
        self.cameraViewModel = cameraViewModel
        self.realmModel = realmModel
    
        let storyboard = UIStoryboard(name: "CameraContent", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "CameraViewController") { coder in
            CameraViewController(
                coder: coder,
                cameraViewModel: cameraViewModel,
                realmModel: realmModel
            )
        }
        
        self.viewController = viewController
        viewController.loadViewIfNeeded() /// needed to initialize outlets
    }
}
