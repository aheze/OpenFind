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
    var searchController: SearchNavigationController
    var mainViewController: SettingsMainViewController
    var detailViewController: SettingsDetailViewController

    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var detailContainer: UIView!
    @IBOutlet weak var mainContainerWidthC: NSLayoutConstraint!
    
    static func make(
        model: SettingsViewModel,
        searchController: SearchNavigationController,
        mainViewController: SettingsMainViewController,
        detailViewController: SettingsDetailViewController
    ) -> SettingsViewController {
        let storyboard = UIStoryboard(name: "SettingsContent", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "SettingsViewController") { coder in
            SettingsViewController(
                coder: coder,
                model: model,
                searchController: searchController,
                mainViewController: mainViewController,
                detailViewController: detailViewController
            )
        }
        return viewController
    }

    init?(
        coder: NSCoder,
        model: SettingsViewModel,
        searchController: SearchNavigationController,
        mainViewController: SettingsMainViewController,
        detailViewController: SettingsDetailViewController
    ) {
        self.model = model
        self.searchController = searchController
        self.mainViewController = mainViewController
        self.detailViewController = detailViewController
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addDebugBorders(.green)
        
        addChildViewController(searchController, in: mainContainer)
        addChildViewController(detailViewController, in: detailContainer)
        updateLayout()
        
        let mainPage = model.page.generateViewController()
        mainViewController.loadViewIfNeeded()
        mainViewController.addChildViewController(mainPage, in: mainViewController.contentView)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateLayout()
    }
    override func viewDidLayoutSubviews() {
        updateLayout()
    }
    
    func updateLayout() {
        if traitCollection.horizontalSizeClass == .compact {
            mainContainerWidthC.constant = view.bounds.width
        } else {
            mainContainerWidthC.constant = view.bounds.width * 0.4
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("You must create this view controller with metadata.")
    }
}
