//
//  ViewController.swift
//  Camera
//
//  Created by Zheng on 11/18/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    lazy var camera: CameraController = CameraBridge.makeController(model: CameraViewModel())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .green
        
        addChild(camera.viewController, in: view)
    }
}
