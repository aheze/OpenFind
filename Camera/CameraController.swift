//
//  Camera.swift
//  Camera
//
//  Created by Zheng on 11/18/21.
//

import UIKit

class CameraController {
    var model: CameraViewModel
    lazy var viewController: CameraViewController = {
        let storyboard = UIStoryboard(name: "CameraContent", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "CameraViewController") { coder in
            CameraViewController(
                coder: coder,
                cameraViewModel: self.model
            )
        }
        
        self.viewController = viewController
        viewController.loadViewIfNeeded() /// needed to initialize outlets
        return viewController
    }()
    
    init(model: CameraViewModel) {
        self.model = model
        _ = viewController
    }
}
