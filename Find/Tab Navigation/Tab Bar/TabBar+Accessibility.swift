//
//  TabBar+Accessibility.swift
//  Find
//
//  Created by Zheng on 3/25/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension TabBarView {
    func setupAccessibility() {
        
        photosIcon.isAccessibilityElement = true
        photosIcon.accessibilityLabel = "Photos"
        photosIcon.accessibilityHint = "Switches to the Photos tab"
        photosIcon.accessibilityTraits = .button
        
        cameraIcon.isAccessibilityElement = true
        cameraIcon.accessibilityLabel = "Camera"
        cameraIcon.accessibilityHint = "Switches to the Camera tab. This button animates and morphs into the Shutter button when active."
        cameraIcon.accessibilityTraits = .button
        
        listsIcon.isAccessibilityElement = true
        listsIcon.accessibilityLabel = "Lists"
        listsIcon.accessibilityHint = "Switches to the Lists tab"
        listsIcon.accessibilityTraits = .button
    }
}
