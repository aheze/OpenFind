//
//  SettingsController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/30/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

class SettingsController {
    var model: SettingsViewModel
    var viewController: SettingsViewController
    var searchViewModel: SearchViewModel
    var realmModel: RealmModel
    
    var searchController: SearchNavigationController
    var mainViewController: SettingsMainViewController
    var detailViewController: SettingsDetailViewController
    
    init(realmModel: RealmModel) {
        let model = SettingsViewModel()
        self.model = model
        
        let searchViewModel = SearchViewModel(configuration: .settings)
        self.searchViewModel = searchViewModel
        
        self.realmModel = realmModel
        let mainViewController = SettingsMainViewController.make(
            model: model,
            searchViewModel: searchViewModel
        )
        let searchController = SearchNavigationController.make(
            rootViewController: mainViewController,
            searchNavigationModel: SearchNavigationModel(),
            searchViewModel: searchViewModel,
            realmModel: realmModel,
            tabType: .photos
        )
        self.mainViewController = mainViewController
        mainViewController.updateSearchBarOffset = {
            searchController.updateSearchBarOffset()
        }
        self.searchController = searchController
        
        let detailViewController = SettingsDetailViewController.make(model: model)
        self.detailViewController = detailViewController
        
        let viewController = SettingsViewController.make(
            model: model,
            searchController: searchController,
            mainViewController: mainViewController,
            detailViewController: detailViewController
        )
        
        self.viewController = viewController
        
        model.updateNavigationBar = {
            searchController.updateSearchBarOffset()
        }
    }
}
