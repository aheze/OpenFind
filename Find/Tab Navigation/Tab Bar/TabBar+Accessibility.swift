//
//  TabBar+Accessibility.swift
//  Find
//
//  Created by Zheng on 3/25/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import SnapKit

extension TabBarView {
    func setupAccessibility() {
        
        photosContainerView.isAccessibilityElement = true
        photosContainerView.accessibilityLabel = "Photos"
        photosContainerView.accessibilityHint = "Switches to the Photos tab"
        photosContainerView.accessibilityTraits = .button
        
        cameraContainerView.isAccessibilityElement = true
        cameraContainerView.accessibilityLabel = "Camera"
        cameraContainerView.accessibilityHint = "Switches to the Camera tab. This button animates and morphs into the Shutter button when active."
        cameraContainerView.accessibilityTraits = .button
        
        listsContainerView.isAccessibilityElement = true
        listsContainerView.accessibilityLabel = "Lists"
        listsContainerView.accessibilityHint = "Switches to the Lists tab"
        listsContainerView.accessibilityTraits = .button
        
        backgroundView.isAccessibilityElement = true
        backgroundView.accessibilityLabel = "Tab bar"
        
        starButton.accessibilityLabel = "Star"
        cacheButton.accessibilityLabel = "Cache"
        photosDeleteButton.accessibilityLabel = "Delete"
        
        starButton.accessibilityHint = "Star selected photos"
        cacheButton.accessibilityHint = "Cache selected photos"
        photosDeleteButton.accessibilityHint = "Delete selected photos"
        
        slideShareButton.accessibilityLabel = "Share"
        slideStarButton.accessibilityLabel = "Star"
        slideCacheButton.accessibilityLabel = "Cache"
        slideDeleteButton.accessibilityLabel = "Delete"
        slideInfoButton.accessibilityLabel = "Info"
        
        slideShareButton.accessibilityHint = "Share photo"
        slideStarButton.accessibilityHint = "Star photo"
        slideCacheButton.accessibilityHint = "Cache photo"
        slideDeleteButton.accessibilityHint = "Delete photo"
        slideInfoButton.accessibilityHint = "Present info screen"
        
        listsDeleteButton.accessibilityLabel = "Delete"
        listsDeleteButton.accessibilityHint = "Delete selected lists"
        
        updateNumberOfSelectedPhotos(to: 0)
    }
    
    func updateNumberOfSelectedPhotos(to number: Int) {
        if number == 1 {
            starButton.accessibilityHint = "Star \(number) selected photo"
            cacheButton.accessibilityHint = "Cache \(number) selected photo"
            photosDeleteButton.accessibilityHint = "Delete \(number) selected photo"
        } else if number == 0 {
            starButton.accessibilityHint = "Select photos first."
            cacheButton.accessibilityHint = "Select photos first."
            photosDeleteButton.accessibilityHint = "Select photos first."
        } else {
            starButton.accessibilityHint = "Star \(number) selected photos"
            cacheButton.accessibilityHint = "Cache \(number) selected photos"
            photosDeleteButton.accessibilityHint = "Delete \(number) selected photos"
        }
    }
}
