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
        
        if UIAccessibility.isVoiceOverRunning {
            setupOneTimeAccessibility()
        }
        
        setupDrawingView()
        setupWarningViews()
        
        newSearchTextField.accessibilityTraits = UIAccessibilityTraits(rawValue: 0x200000000000)
        newSearchTextField.accessibilityLabel = "Search bar"
        
        listsLabel.accessibilityLabel = "Selected Lists"
        listsLabel.accessibilityHint = "The current active lists"
        listsLabel.accessibilityTraits = .header
        
        textLabel.accessibilityLabel = "Text"
        textLabel.accessibilityHint = "Text to look for"
        textLabel.accessibilityTraits = .header
        
        listsDownIndicatorView.isAccessibilityElement = true
        listsDownIndicatorView.accessibilityLabel = "Down arrow icon. Double-tap the below lists to remove."
        listsDownIndicatorView.accessibilityTraits = .staticText
        
        cameraIconHolder.isAccessibilityElement = true
        cameraIconHolder.accessibilityLabel = "Shutter, pause"
        cameraIconHolder.accessibilityHint = "Pauses the camera, shows the Save and Cache buttons, and disables the flashlight"
        cameraIconHolder.accessibilityTraits = .button
        
        statsView.isAccessibilityElement = true
        statsView.accessibilityLabel = "Stats"
        statsView.accessibilityHint = "Presents the Stats screen. Focus to continuously announce how many results there are currently, if more than 0."
        statsView.accessibilityValue = "0"
        statsView.accessibilityTraits = [.button]
        statsView.currentlyFocused = { [weak self] focused in
            guard let self = self else { return }
            self.statsFocused = focused
        }
        
        fullScreenView.isAccessibilityElement = true
        fullScreenView.accessibilityLabel = "Full screen"
        fullScreenView.accessibilityHint = "Hides the search field, tab bar, shutter button, and everything else"
        fullScreenView.accessibilityTraits = [.button]
        
        showControlsButton.accessibilityHint = "Exit full screen mode"
        
        flashView.isAccessibilityElement = true
        flashView.accessibilityLabel = "Flashlight"
        flashView.accessibilityHint = "Turns on the flashlight"
        flashView.accessibilityValue = "Off"
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
        
        searchBackgroundView.isAccessibilityElement = true
        searchBackgroundView.accessibilityLabel = "Search controls"
        searchBackgroundView.accessibilityHint = "Contains the search bar and all selected lists"
        
        if UIAccessibility.isVoiceOverRunning {
            setupOneTimeAccessibility()
        } else {
            messageView.isHidden = false
            searchBackgroundView.isHidden = true
        }
        
        topGroupView.accessibilityElements = [searchBackgroundView, newSearchTextField]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            UIAccessibility.post(notification: .screenChanged, argument: self.newSearchTextField)
        }
        
        view.accessibilityElements = [topGroupView, warningView, alternateWarningView, whatsNewView, cameraGroupView, passthroughGroupView]
    }
    
    /// add views, etc
    func setupOneTimeAccessibility() {
        AccessibilityState.cameraDidSetup = true
        
        
        messageView.isHidden = true
        searchBackgroundView.isHidden = false
        
        statsWidthC.constant = 50
        statsHeightC.constant = 50
        fullScreenWidthC.constant = 50
        fullScreenHeightC.constant = 50
        flashWidthC.constant = 50
        flashHeightC.constant = 50
        settingsWidthC.constant = 50
        settingsHeightC.constant = 50
        
        let controlsView = UIView()
        passthroughGroupView.insertSubview(controlsView, at: 0)

        controlsView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        controlsView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        controlsView.isAccessibilityElement = true
        controlsView.accessibilityLabel = "Camera controls"
        controlsView.accessibilityHint = "Contains Stats, Full Screen, Shutter, Flashlight, and Settings buttons. When camera is paused, also contains Save and Cache buttons"
        controlsView.accessibilityTraits = .none
        
        passthroughGroupView.passthroughActive = false
        passthroughGroupView.isAccessibilityElement = false
        passthroughGroupView.accessibilityElements = [controlsView, statsView, fullScreenView, cameraIconHolder, flashView, settingsView]
        
        self.controlsView = controlsView
        
    }
    
    func setupDrawingView() {
        
        drawingBaseView.isAccessibilityElement = true
        drawingBaseView.accessibilityLabel = "Viewfinder"
        drawingBaseView.accessibilityHint = "Pause the shutter to explore highlights, then double-tap them to toggle transcript overlay."
        drawingBaseView.activated = { [weak self] in
            guard let self = self else { return false }
            
            if CameraState.isPaused {
                self.showingTranscripts.toggle()
                if self.showingTranscripts {
                    self.showTranscripts()
                } else {
                    self.showHighlights()
                }
                return true
            }
            
            return false
        }
    }
    
    func setupWarningViews() {
        warningLabel.accessibilityLabel = "Find is paused. Duplicates are not allowed."
        
        let onlyPortraitSupported = NSLocalizedString("onlyPortraitSupported", comment: "SetupSearchBar def=Only Portrait view is currently supported.")
        let rotateToPortrait = NSLocalizedString("rotateToPortrait", comment: "SetupSearchBar def=Please rotate your iPad to Portrait view, then relaunch the app.")
        
        alternateWarningLabel.accessibilityLabel = "\(onlyPortraitSupported)\n\(rotateToPortrait)"
        
        whatsNewButton.accessibilityLabel = "See what's new in Find!"
        
    }
    
    func pausedAccessibility(paused: Bool) {
        if paused {
            
            for component in currentComponents {
                if
                    let baseView = component.baseView,
                    let componentColors = self.matchToColors[component.text],
                    let firstHexString = componentColors.first?.hexString
                {
                    
                    self.addAccessibilityLabel(component: component, newView: baseView, hexString: firstHexString)
                }
            }
        
            drawAllTranscripts(show: false)
        
            controlsView?.accessibilityHint = "Contains Stats, Full Screen, Save, Shutter, Cache, Flashlight, and Settings buttons."
            passthroughGroupView.accessibilityElements = [controlsView, statsView, fullScreenView, saveToPhotos, cameraIconHolder, cache, flashView, settingsView]
            
            cameraIconHolder.accessibilityLabel = "Shutter, play"
            cameraIconHolder.accessibilityHint = "Starts the camera, removes the Save and Cache buttons, and enables the flashlight to be turned on"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                print("Speaking...")
                if TipViews.currentLocalStep != 2 { /// must not be in a tutorial first
                    print("tu")
                    UIAccessibility.post(notification: .announcement, argument: "\(self.currentNumberOfMatches) results found. Drag your finger over the Viewfinder to explore highlights. Cache for better accuracy.")
                }
                
            }
            drawingBaseView.accessibilityHint = ""
        } else {
            controlsView?.accessibilityHint = "Contains Stats, Full Screen, Shutter, Flashlight, and Settings buttons. When camera is paused, also contains Save and Cache"
            passthroughGroupView.accessibilityElements = [controlsView, statsView, fullScreenView, cameraIconHolder, flashView, settingsView]
            
            cameraIconHolder.accessibilityLabel = "Shutter, pause"
            cameraIconHolder.accessibilityHint = "Pauses the camera, shows the Save and Cache buttons, and disables the flashlight"
            
            drawingBaseView.accessibilityHint = "Highlights will be placed on detected results. Pause shutter to explore."
        }
    }
}
