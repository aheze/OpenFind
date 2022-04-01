//
//  ViewController.swift
//  Camera
//
//  Created by Zheng on 11/18/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let realmModel = RealmModel()
    lazy var tabViewModel = TabViewModel()
    lazy var toolbarViewModel = ToolbarViewModel()
    
    lazy var camera = CameraController(
        model: CameraViewModel(),
        tabViewModel: tabViewModel,
        realmModel: RealmModel()
    )

    lazy var tabController: TabBarController = {
        let tabController = TabBarController(
            pages: [camera.viewController],
            model: tabViewModel,
            cameraViewModel: CameraViewModel(),
            toolbarViewModel: toolbarViewModel
        )

        return tabController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tabViewModel.tabState = .camera
        addChildViewController(tabController.viewController, in: view)
    }
}
