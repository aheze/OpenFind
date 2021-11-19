//
//  Camera.swift
//  Camera
//
//  Created by Zheng on 11/18/21.
//

import UIKit

public class CameraController {
    public var viewController: CameraViewController
    
    init() {
        let bundle = Bundle(identifier: "com.aheze.Camera")
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        let viewController = storyboard.instantiateViewController(withIdentifier: "CameraViewController") as! CameraViewController
        self.viewController = viewController
        viewController.loadViewIfNeeded() /// needed to initialize outlets
    }
}
