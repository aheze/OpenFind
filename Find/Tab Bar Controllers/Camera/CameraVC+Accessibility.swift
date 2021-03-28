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
        
        drawingView.isAccessibilityElement = true
        drawingView.accessibilityLabel = "Viewfinder"
        drawingView.accessibilityHint = "Highlights will be placed on detected results."

        newSearchTextField.accessibilityTraits = UIAccessibilityTraits(rawValue: 0x200000000000)
        
        cameraIconHolder.isAccessibilityElement = true
        cameraIconHolder.accessibilityLabel = "Shutter, pause"
        cameraIconHolder.accessibilityHint = "Pauses the camera, shows the Save and Cache buttons, and disables the flashlight"
        cameraIconHolder.accessibilityTraits = [.button, UIAccessibilityTraits(rawValue: 0x200000000000)]
        
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
        
        saveToPhotos.isAccessibilityElement = true
        saveToPhotos.accessibilityLabel = "Save to Photos"
        saveToPhotos.accessibilityHint = "Saves the current paused image to the photo library"
        saveToPhotos.accessibilityTraits = [.button]
        
        cache.isAccessibilityElement = true
        cache.accessibilityLabel = "Cache"
        cache.accessibilityHint = "Caches the current paused image. Produces much more accurate results."
        cache.accessibilityTraits = [.button]
        
        if UIAccessibility.isVoiceOverRunning {
            statsWidthC.constant = 50
            statsHeightC.constant = 50
            fullScreenWidthC.constant = 50
            fullScreenHeightC.constant = 50
            flashWidthC.constant = 50
            flashHeightC.constant = 50
            settingsWidthC.constant = 50
            settingsHeightC.constant = 50
            
            let controlsView = UIView()
            passthroughView.insertSubview(controlsView, at: 0)

            controlsView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            controlsView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            controlsView.isAccessibilityElement = true
            controlsView.accessibilityLabel = "Camera controls"
            controlsView.accessibilityHint = "Contains Stats, Full Screen, Shutter, Flashlight, and Settings buttons. When camera is paused, also contains Save and Cache buttons"
            controlsView.accessibilityTraits = .none
            
            passthroughView.passthroughActive = false
            passthroughView.isAccessibilityElement = false
            passthroughView.accessibilityElements = [controlsView, statsView, fullScreenView, cameraIconHolder, flashView, settingsView]
            
            self.controlsView = controlsView
            
            messageView.isHidden = true
        }
        
    }
    
    func pausedAccessibility(paused: Bool) {
        if paused {
            controlsView?.accessibilityHint = "Contains Stats, Full Screen, Save, Shutter, Cache, Flashlight, and Settings buttons."
            passthroughView.accessibilityElements = [controlsView, statsView, fullScreenView, saveToPhotos, cameraIconHolder, cache, flashView, settingsView]
            
            cameraIconHolder.accessibilityLabel = "Shutter, play"
            cameraIconHolder.accessibilityHint = "Starts the camera, removes the Save and Cache buttons, and enables the flashlight to be turned on"
        } else {
            controlsView?.accessibilityHint = "Contains Stats, Full Screen, Shutter, Flashlight, and Settings buttons. When camera is paused, also contains Save and Cache"
            passthroughView.accessibilityElements = [controlsView, statsView, fullScreenView, cameraIconHolder, flashView, settingsView]
            
            cameraIconHolder.accessibilityLabel = "Shutter, pause"
            cameraIconHolder.accessibilityHint = "Pauses the camera, shows the Save and Cache buttons, and disables the flashlight"
        }
    }
}
