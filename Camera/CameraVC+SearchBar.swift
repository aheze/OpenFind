//
//  CameraVC+SearchBar.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/28/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//
    
import UIKit

extension CameraViewController {
    func createSearchBar() -> SearchViewController {
        let searchViewController = SearchViewController.make(searchViewModel: searchViewModel, realmModel: realmModel)
        searchContainerView.backgroundColor = .clear
        addResizableChildViewController(searchViewController, in: searchContainerView)
        
        searchViewModel.fieldsChanged = { [weak self] oldValue, newValue in
            guard let self = self else { return }
            
            let oldText = oldValue.map { $0.value.getText() }
            let newText = newValue.map { $0.value.getText() }
            let textIsSame = oldText == newText
            
            if textIsSame {
                /// replace all highlights
                self.updateHighlightColors()
            } else {
                self.highlightsViewModel.setUpToDate(false)
                
                
                /// animate the highlight frames instead if paused
                if
                    self.model.shutterOn,
                    let sentences = self.model.pausedImage?.sentences
                {
                    let highlights = self.getHighlights(from: sentences)
                    DispatchQueue.main.async {
                        self.highlightsViewModel.update(with: highlights, replace: true)
                    }
                }
            }
        }
        
        return searchViewController
    }
}
