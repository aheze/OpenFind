//
//  ViewController+Accessibility.swift
//  Find
//
//  Created by Zheng on 3/31/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension ViewController {
    func observeVoiceOverChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(voiceOverChanged),
            name: UIAccessibility.voiceOverStatusDidChangeNotification,
            object: nil
        )
    }
    
    @objc func voiceOverChanged() {
        if UIAccessibility.isVoiceOverRunning {
            if !AccessibilityState.cameraDidSetup {
                camera.setupAccessibility()
            }
        }
    }
}
