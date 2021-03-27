//
//  SegmentedSlider+Accessibility.swift
//  Find
//
//  Created by Zheng on 3/25/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension SegmentedSlider {
    func setupAccessibility() {
        
//        localLabel.accessibilityHint = "Displays only Local photos in the photo gallery. Local photos are photos that are saved from Find, by pressing the Save button when the camera is paused."
//        localLabel.accessibilityTraits = .button
//
//        starredLabel.accessibilityHint = "Displays only starred photos in the photo gallery"
//        starredLabel.accessibilityTraits = .button
//
//        cachedLabel.accessibilityHint = "Displays only cached photos in the photo gallery"
//        cachedLabel.accessibilityTraits = .button
//
//        allLabel.accessibilityHint = "Displays all your photos in the photo gallery"
//        allLabel.accessibilityTraits = [.button, .selected]
        
        self.isAccessibilityElement = true
        self.accessibilityLabel = "Filters"
        self.accessibilityTraits = .adjustable
        self.shouldGroupAccessibilityChildren = true
        
    }
    
    
}
