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
    var listsViewModel: ListsViewModel
    
    init(cameraViewModel: CameraViewModel, listsViewModel: ListsViewModel) {
        self.cameraViewModel = cameraViewModel
        self.listsViewModel = listsViewModel
    
        let storyboard = UIStoryboard(name: "CameraContent", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "CameraViewController") { coder in
            CameraViewController(
                coder: coder,
                cameraViewModel: cameraViewModel,
                listsViewModel: listsViewModel
            )
        }
        
        self.viewController = viewController
        viewController.loadViewIfNeeded() /// needed to initialize outlets
    }
}
