//
//  ViewController.swift
//  Lists
//
//  Created by Zheng on 11/18/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    lazy var lists: ListsController = ListsBridge.makeController(
        listsViewModel: ListsViewModel()
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        addChildViewController(lists.navigationController, in: view)
    }
}
