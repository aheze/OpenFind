//
//  ViewController.swift
//  Lists
//
//  Created by Zheng on 11/18/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    lazy var lists: ListsController = {
        return ListsBridge.makeController()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        addChild(lists.viewController, in: view)
    }
}

