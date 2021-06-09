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
        var prompt = ""
        
        let findingFrom = "Find from"
        let unit = NSLocalizedString("unitZhang", comment: "")
        let all = NSLocalizedString("allSpace", comment: "")
        let space = NSLocalizedString("blankSpace", comment: "")
        let photos = NSLocalizedString("findingFrom-photos", comment: "")
        
        
        var number = (numberOfSelected == 0) ? all : "\(numberOfSelected)\(unit)\(space)" /// number of all
        
        var overriddenLastPart: String?
        
        let filter: String
//        switch photoFilterState {
//
//        case .local:
//            filter = "\(NSLocalizedString("lowercaseLocal", comment: ""))\(space)"
//        case .screenshots:
//            filter = "\(NSLocalizedString("lowercaseScreenshot", comment: ""))\(space)"
//        case .all:
//            filter = all
//            if numberOfSelected == 0 {
//                number = ""
//            } else {
//                let withinAllPhotos = NSLocalizedString("withinAllPhotos-Chinese", comment: "")
//                if withinAllPhotos != "" { /// English is blank string
//                    overriddenLastPart = "\(withinAllPhotos)\(numberOfSelected)\(unit)查找"
//                } else {
//                    number = "\(numberOfSelected) of "
//                }
//            }
//        }
        
//        if let overriddenLastPart = overriddenLastPart {
//            prompt = findingFrom + filter + overriddenLastPart
//        } else {
//            prompt = findingFrom + number + filter + photos
//        }
        
        prompt += ". Presents the Finding sheet."
        
        findButton?.accessibilityHint = prompt
    }
}
