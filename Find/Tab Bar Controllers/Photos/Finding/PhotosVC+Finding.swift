//
//  PhotosVC+Finding.swift
//  Find
//
//  Created by Zheng on 1/15/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotosViewController {
    func setUpFinding() {
        collapseButton.layer.cornerRadius = 16
        collapseButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        collapseButton.alpha = 0
    }
    func findPressed() {
//        findWithFilter?(currentFilter)
        switchToFind?(currentFilter, allPhotosToDisplay)
        
        UIView.animate(withDuration: 0.5) {
            self.segmentedSlider.alpha = 0
            self.collapseButton.alpha = 1
        }
        
        

//        switch currentFilter {
//        case .local:
//            <#code#>
//        case .starred:
//            <#code#>
//        case .cached:
//            <#code#>
//        case .all:
//            <#code#>
//        }
        
    }
}
