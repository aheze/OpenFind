//
//  Camera.swift
//  Camera
//
//  Created by Zheng on 11/18/21.
//

import UIKit

class CameraController {
    var model: CameraViewModel
    var viewController: CameraViewController
    
    init(model: CameraViewModel) {
        self.model = model
        
        let storyboard = UIStoryboard(name: "CameraContent", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "CameraViewController") { coder in
            CameraViewController(coder: coder, cameraViewModel: model)
        }
        
        self.viewController = viewController
        viewController.loadViewIfNeeded() /// needed to initialize outlets
    }
}
