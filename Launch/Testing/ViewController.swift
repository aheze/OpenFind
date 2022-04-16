//
//  ViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    lazy var model = LaunchViewModel()
    lazy var launchViewController = LaunchViewController.make(model: model)

    override func viewDidLoad() {
        super.viewDidLoad()

        _ = launchViewController
        addChildViewController(launchViewController, in: view)
    }
}
