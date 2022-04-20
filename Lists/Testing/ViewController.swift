//
//  ViewController.swift
//  Lists
//
//  Created by Zheng on 11/18/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let realmModel = RealmModel()
    lazy var tabViewModel = TabViewModel()
    lazy var toolbarViewModel = ToolbarViewModel()
    lazy var lists = ListsController(
        model: ListsViewModel(),
        tabViewModel: TabViewModel(),
        toolbarViewModel: toolbarViewModel,
        realmModel: realmModel
    )
    
    lazy var tabController: TabBarController = {
        let tabController = TabBarController(
            pages: [lists.searchNavigationController],
            model: tabViewModel,
            realmModel: realmModel,
            cameraViewModel: CameraViewModel(),
            toolbarViewModel: toolbarViewModel
        )

        return tabController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        realmModel.container.loadLists()
        tabViewModel.tabState = .lists
        addChildViewController(lists.searchNavigationController, in: view)
    }
}
