//
//  SettingsViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/30/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    var model: SettingsViewModel
    var split: UISplitViewController!
    var mainViewController: SettingsMainViewController
    var detailViewController: SettingsDetailViewController

    static func make(
        model: SettingsViewModel,
        mainViewController: SettingsMainViewController,
        detailViewController: SettingsDetailViewController
    ) -> SettingsViewController {
        let storyboard = UIStoryboard(name: "SettingsContent", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "SettingsViewController") { coder in
            SettingsViewController(
                coder: coder,
                model: model,
                mainViewController: mainViewController,
                detailViewController: detailViewController
            )
        }
        return viewController
    }

    init?(
        coder: NSCoder,
        model: SettingsViewModel,
        mainViewController: SettingsMainViewController,
        detailViewController: SettingsDetailViewController
    ) {
        self.model = model
        self.mainViewController = mainViewController
        self.detailViewController = detailViewController

        let split = UISplitViewController(style: .doubleColumn)
        split.preferredDisplayMode = .oneBesideSecondary
        self.split = split
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        split.delegate = self
        addChildViewController(split, in: view)
        split.viewControllers = [mainViewController, detailViewController]
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("You must create this view controller with metadata.")
    }
}

extension SettingsViewController: UISplitViewControllerDelegate {
    /// https://stackoverflow.com/a/64197616/14351818
    @available(iOS 14.0, *)
    func splitViewController(_ svc: UISplitViewController, topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column) -> UISplitViewController.Column {
        return .primary
    }

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}
