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

    
    init(model: IconPickerViewModel) {
        var searchViewModel = SearchViewModel(configuration: .photos)
        self.searchViewModel = searchViewModel
        
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
            searchViewModel: searchViewModel,
            tabType: .lists
        )
        
        self.searchNavigationController = searchNavigationController
        self.iconPickerViewController = iconPickerViewController
        
        
        iconPickerViewController.updateSearchBarOffset = { [weak self] in
            guard let self = self else { return }
            self.searchNavigationController.updateSearchBarOffset()
        }
        
        searchNavigationController.searchViewModel.fieldsChanged = { [weak self] oldValue, newValue in
            guard let self = self else { return }
            
            let oldText = oldValue.map { $0.value.getText() }
            let newText = newValue.map { $0.value.getText() }
            let textIsSame = oldText == newText
            
            if !textIsSame {
                let search = newText.filter { !$0.isEmpty }
                self.iconPickerViewController.model.filter(search: search) {
                    self.iconPickerViewController.update()
                }
            }
        }
    }
}
