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
    var launchViewController: LaunchViewController?

    func removeLaunchViewController() {
        if let launchViewController = launchViewController {
            removeChildViewController(launchViewController)
            self.launchViewController = nil
        }
    }

    override var childForStatusBarStyle: UIViewController? {
        return launchViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)

        view.backgroundColor = .green

        let launchViewController = LaunchViewController.make(model: model)
        self.launchViewController = launchViewController

        addChildViewController(launchViewController, in: view)

        launchViewController.entering = { [weak self] in
            guard let self = self else { return }
        }

        launchViewController.done = { [weak self] in
            guard let self = self else { return }
            self.removeLaunchViewController()
        }
    }
}
