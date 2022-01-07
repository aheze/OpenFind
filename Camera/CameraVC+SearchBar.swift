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
        let searchViewController = Bridge.makeViewController(searchViewModel: searchViewModel)
        
        searchContainerView.backgroundColor = .clear
        addResizableChildViewController(searchViewController, in: searchContainerView)
        
        searchViewModel.fieldsChanged = { [weak self] in
            guard let self = self else { return }
            self.updateHighlightColors()
            self.invalidateHighlightColors()
            
            if
                self.cameraViewModel.shutterOn,
                let image = self.cameraViewModel.pausedImage
            {
                self.findAndAddHighlights(image: image)
            }
        }
        
        return searchViewController
    }
}
