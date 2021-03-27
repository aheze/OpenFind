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
        
        if UIAccessibility.isVoiceOverRunning {
            
        }
    }
}
