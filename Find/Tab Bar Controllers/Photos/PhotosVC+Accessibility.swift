//
//  PhotosVC+Accessibility.swift
//  Find
//
//  Created by Zheng on 3/25/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotosViewController {
    func setupAccessibility() {
        collapseButton?.isAccessibilityElement = false
        
        extendedCollapseButton?.isHidden = true /// hide when photos active
        
        collapseButton?.accessibilityLabel = "Back to Photo Gallery"
        collapseButton?.accessibilityHint = "Dismisses the photo finding screen"
        extendedCollapseButton?.accessibilityLabel = "Back to Photo Gallery"
        extendedCollapseButton?.accessibilityHint = "Dismisses the photo finding screen"
        
        updateFindButtonHint()
        
        selectButton?.accessibilityHint = "Enter select mode"
        
        collectionView?.isAccessibilityElement = false
    }
    
    func updateFindButtonHint() {
        let findingFrom = "Find from "
        var number = "\(numberOfSelected) "
        var filter = ""
        var folder: String
        
        var combinedPromptString = ""
        
        if photoFilterState.starSelected || photoFilterState.cacheSelected {
            if photoFilterState.starSelected, photoFilterState.cacheSelected {
                filter = "starred + cached "
            } else if photoFilterState.starSelected {
                filter = "starred "
            } else {
                filter = "cached "
            }
        }
        
        if numberOfSelected == 0 {
            number = "\(allPhotosToDisplay.count) "
        }
        
        switch photoFilterState.currentFilter {
        case .local:
            folder = "local photos"
        case .screenshots:
            folder = "screenshots"
        case .all:
            folder = "photos"
            
            /// is all photos
            if numberOfSelected == 0 {
                number = "all \(number) "
            } else {
                number = "\(number)of all "
            }
        }
        
        if combinedPromptString.isEmpty {
            combinedPromptString = findingFrom + number + filter + folder
        }
        
        combinedPromptString += ". Presents the Finding sheet."
        
        findButton?.accessibilityHint = combinedPromptString
    }
}
