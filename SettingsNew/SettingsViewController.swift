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
    var realmModel: RealmModel
    var searchController: SearchNavigationController
    var mainViewController: SettingsMainViewController
    
    lazy var colorPickerViewModel = ColorPickerViewModel(selectedColor: UIColor(hex: realmModel.highlightsColor.uInt))

    @IBOutlet var mainContainer: UIView!


    static func make(
        model: SettingsViewModel,
        realmModel: RealmModel,
        searchController: SearchNavigationController,
        mainViewController: SettingsMainViewController
    ) -> SettingsViewController {
        let storyboard = UIStoryboard(name: "SettingsContent", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "SettingsViewController") { coder in
            SettingsViewController(
                coder: coder,
                model: model,
                realmModel: realmModel,
                searchController: searchController,
                mainViewController: mainViewController
            )
        }
        return viewController
    }

    init?(
        coder: NSCoder,
        model: SettingsViewModel,
        realmModel: RealmModel,
        searchController: SearchNavigationController,
        mainViewController: SettingsMainViewController
    ) {
        self.model = model
        self.realmModel = realmModel
        self.searchController = searchController
        self.mainViewController = mainViewController
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addChildViewController(searchController, in: mainContainer)
        updatePageWidth()
        listen()
    }

    override func viewDidLayoutSubviews() {
        updatePageWidth()
    }

    func updatePageWidth() {
        model.pageWidth = view.bounds.width
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("You must create this view controller with metadata.")
    }
}


