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
    lazy var lists = ListsController(model: ListsViewModel(), tabViewModel: TabViewModel(), toolbarViewModel: ToolbarViewModel(), realmModel: RealmModel())
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        addChildViewController(lists.searchNavigationController, in: view)
    }
}
