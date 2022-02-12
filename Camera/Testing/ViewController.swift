//
//  ViewController.swift
//  Camera
//
//  Created by Zheng on 11/18/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    lazy var camera: CameraController = CameraBridge.makeController(
        cameraViewModel: CameraViewModel(),
        realmModel: RealmModel()
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .green
        addChildViewController(camera.viewController, in: view)
        camera.viewController.addTestingTabBar(add: true)
    }
}
