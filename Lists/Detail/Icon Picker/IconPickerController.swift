//
//  IconPickerController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/26/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

class IconPickerController {
    var searchNavigationController: SearchNavigationController
    var iconPickerViewController: IconPickerViewController
    var searchViewModel: SearchViewModel
    var realmModel: RealmModel
    
    init(model: IconPickerViewModel, realmModel: RealmModel) {
        let searchNavigationModel = SearchNavigationModel()
        let searchViewModel = SearchViewModel(configuration: .icons)
        self.searchViewModel = searchViewModel
        self.realmModel = realmModel
        
        let storyboard = UIStoryboard(name: "ListsContent", bundle: nil)
        let iconPickerViewController = storyboard.instantiateViewController(identifier: "IconPickerViewController") { coder in
            IconPickerViewController(
                coder: coder,
                model: model,
                searchViewModel: searchViewModel
            )
        }
        let searchNavigationController = SearchNavigationController.make(
            rootViewController: iconPickerViewController,
            searchNavigationModel: searchNavigationModel,
            searchViewModel: searchViewModel,
            realmModel: realmModel,
            tabType: .lists
        )
        
        self.searchNavigationController = searchNavigationController
        self.iconPickerViewController = iconPickerViewController
        
        
        iconPickerViewController.updateSearchBarOffset = { [weak self] in
            guard let self = self else { return }
            self.searchNavigationController.updateSearchBarOffset()
        }
        
        searchNavigationController.searchViewModel.fieldsChanged = { [weak self] textChanged in
            guard let self = self else { return }
            
            if textChanged {
                let search = self.searchNavigationController.searchViewModel.text
                self.iconPickerViewController.model.filter(search: search) {
                    self.iconPickerViewController.update()
                }
            }
        }
    }
}
