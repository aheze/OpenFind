//
//  ViewController.swift
//  Photos
//
//  Created by Zheng on 11/18/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    lazy var photos = PhotosController(
        model: PhotosViewModel(
            realmModel: RealmModel()
        ),
        tabViewModel: TabViewModel(),
        toolbarViewModel: ToolbarViewModel()
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        addChildViewController(photos.searchNavigationController, in: view)
    }
}
