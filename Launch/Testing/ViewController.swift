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
    lazy var launchViewController = LaunchViewController.make(model: model) { [weak self] in
        guard let self = self else { return }
        self.removeLaunchViewController()
    }

    func removeLaunchViewController() {
        removeChildViewController(launchViewController)
    }

    override var childForStatusBarStyle: UIViewController? {
        return launchViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)

        view.backgroundColor = .green

        _ = launchViewController
        addChildViewController(launchViewController, in: view)
    }
}
