//
//  ViewController.swift
//  Photos
//
//  Created by Zheng on 11/18/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    lazy var tabViewModel = TabViewModel()
    lazy var toolbarViewModel = ToolbarViewModel()
    lazy var realmModel = RealmModel()
    lazy var photos = PhotosController(
        model: PhotosViewModel(),
        realmModel: realmModel,
        tabViewModel: tabViewModel,
        toolbarViewModel: toolbarViewModel
    )

    lazy var tabController: TabBarController = {
        let tabController = TabBarController(
            pages: [photos.searchNavigationController],
            model: tabViewModel,
            realmModel: realmModel,
            cameraViewModel: CameraViewModel(),
            toolbarViewModel: toolbarViewModel
        )

        return tabController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        tabViewModel.tabState = .photos
        addChildViewController(tabController.viewController, in: view)
    }
}
