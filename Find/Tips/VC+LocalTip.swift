//
//  VC+LocalTip.swift
//  Find
//
//  Created by Zheng on 1/27/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension ViewController {
    func startLocalTutorial() {
        TipViews.inTutorial = true
        
        var preferences = EasyTipView.globalPreferences
        preferences.drawing.backgroundColor = UIColor(named: "PopTipLocal")!
        preferences.drawing.arrowPosition = .bottom
        
        preferences.drawing.shadowColor = #colorLiteral(red: 0.4207544327, green: 0.4207544327, blue: 0.4207544327, alpha: 1)
        preferences.drawing.shadowOpacity = 0.5
        preferences.drawing.shadowRadius = 2
        
        let goToCamera = NSLocalizedString("tip-goToCamera", comment: "")
        let tipView = EasyTipView(text: goToCamera, preferences: preferences, delegate: self)
        tipView.show(forView: tabBarView.cameraContainerView)
        
        TipViews.localTipView1 = tipView
        TipViews.currentLocalStep = 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            UIAccessibility.post(notification: .layoutChanged, argument: self.tabBarView.cameraContainerView)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                let stepText = AccessibilityText(text: "Step 1.", customPitch: 0.7)
                let instructions = AccessibilityText(text: "Double-tap the camera button in the tab bar", isRaised: false)
                UIAccessibility.post(notification: .announcement, argument: UIAccessibility.makeAttributedText([stepText, instructions]))
            }
        }
    }
    func startLocalSecondStep() {
        TipViews.localTipView1?.dismiss()
        
        var preferences = EasyTipView.globalPreferences
        preferences.drawing.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6)
        preferences.drawing.arrowPosition = .bottom
        
        let pauseThePreview = NSLocalizedString("tip-pauseThePreview", comment: "")
        let tipView = EasyTipView(text: pauseThePreview, preferences: preferences, delegate: self)
        tipView.show(forView: camera.cameraIconHolder, withinSuperview: camera.view)
        
        
        TipViews.localTipView2 = tipView
        TipViews.currentLocalStep = 2
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            UIAccessibility.post(notification: .layoutChanged, argument: self.camera.cameraIconHolder)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                let stepText = AccessibilityText(text: "Step 2.", customPitch: 0.7)
                let instructions = AccessibilityText(text: "Double-tap the shutter to pause", isRaised: false)
                UIAccessibility.post(notification: .announcement, argument: UIAccessibility.makeAttributedText([stepText, instructions]))
            }
        }
    }
    
}
