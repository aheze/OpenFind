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
    
    init(realmModel: RealmModel) {
        let model = SettingsViewModel()
        self.model = model
        
        let searchViewModel = SearchViewModel(configuration: .settings)
        self.searchViewModel = searchViewModel
        
        self.realmModel = realmModel
        let mainViewController = SettingsMainViewController.make(
            model: model,
            realmModel: realmModel,
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
        self.searchController = searchController
        
        let viewController = SettingsViewController.make(
            model: model,
            realmModel: realmModel,
            searchController: searchController,
            mainViewController: mainViewController
        )
        
        self.viewController = viewController
        
        /// listen to closures
        listen()
    }
}
