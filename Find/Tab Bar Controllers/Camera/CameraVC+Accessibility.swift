//
//  CameraVC+Accessibility.swift
//  Find
//
//  Created by Zheng on 3/25/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension CameraViewController {
    func setupAccessibility() {
        print("settng up...")
        cameraIconHolder.isAccessibilityElement = true
        cameraIconHolder.accessibilityLabel = "Shutter, play"
        cameraIconHolder.accessibilityHint = "Pauses the camera, shows the Save and Cache buttons, and disables the flashlight"
        cameraIconHolder.accessibilityTraits = [.button]
        
        statsView.isAccessibilityElement = true
        statsView.accessibilityLabel = "Statistics"
        statsView.accessibilityHint = "Presents the Stats screen"
        statsView.accessibilityTraits = [.button]
        
        fullScreenView.isAccessibilityElement = true
        fullScreenView.accessibilityLabel = "Full screen"
        fullScreenView.accessibilityHint = "Hides the search field, tab bar, shutter button, and everything else"
        fullScreenView.accessibilityTraits = [.button]
        
        flashView.isAccessibilityElement = true
        flashView.accessibilityLabel = "Flashlight"
        flashView.accessibilityHint = "Turns on the flashlight"
        flashView.accessibilityTraits = [.button]
        
        settingsView.isAccessibilityElement = true
        settingsView.accessibilityLabel = "Settings"
        settingsView.accessibilityHint = "Presents the Settings screen"
        settingsView.accessibilityTraits = [.button]
    }
}
