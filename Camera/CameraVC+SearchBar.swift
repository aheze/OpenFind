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
        
        searchViewModel.fieldsChanged = { [weak self] textChanged in
            guard let self = self else { return }
            
            if textChanged {
                self.highlightsViewModel.setUpToDate(false)
                
                if self.searchViewModel.isEmpty {
                    self.highlightsViewModel.highlights = []
                    self.highlightsAdded()
                } else {
                    /// animate the highlight frames instead if paused
                    if
                        self.model.shutterOn,
                        let sentences = self.model.pausedImage?.sentences
                    {
                        let highlights = sentences.getHighlights(stringToGradients: self.searchViewModel.stringToGradients, realmModel: self.realmModel)
                        DispatchQueue.main.async {
                            self.highlightsViewModel.update(with: highlights, replace: true)
                            self.highlightsAdded()
                        }
                    }
                }
            } else {
                /// replace all highlights
                self.updateHighlightColors()
            }
        }
        
        return searchViewController
    }
}
