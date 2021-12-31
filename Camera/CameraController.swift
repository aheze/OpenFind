//
//  Camera.swift
//  Camera
//
//  Created by Zheng on 11/18/21.
//

import UIKit

class CameraController {
    var cameraViewModel: CameraViewModel
    var listsViewModel: ListsViewModel
    
    lazy var viewController: CameraViewController = {
        let storyboard = UIStoryboard(name: "CameraContent", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "CameraViewController") { coder in
            CameraViewController(
                coder: coder,
                cameraViewModel: self.cameraViewModel,
                listsViewModel: self.listsViewModel
            )
        }
        
        self.viewController = viewController
        viewController.loadViewIfNeeded() /// needed to initialize outlets
        return viewController
    }()
    
    init(cameraViewModel: CameraViewModel, listsViewModel: ListsViewModel) {
        self.cameraViewModel = cameraViewModel
        self.listsViewModel = listsViewModel
        _ = viewController
    }
}
