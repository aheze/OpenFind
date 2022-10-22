//
//  VC+StarTip.swift
//  Find
//
//  Created by Zheng on 1/27/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension ViewController {
    func startStarTutorial() {
        TipViews.dismissAll()
        TipViews.inTutorial = true
        
        var preferences = EasyTipView.globalPreferences
        preferences.drawing.backgroundColor = UIColor(named: "PopTipGold")!
        preferences.drawing.arrowPosition = .bottom
        
        preferences.drawing.shadowColor = #colorLiteral(red: 0.4207544327, green: 0.4207544327, blue: 0.4207544327, alpha: 1)
        preferences.drawing.shadowOpacity = 0.5
        preferences.drawing.shadowRadius = 2
        
        preferences.positioning.bubbleInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        
        let switchToAllPhotos = NSLocalizedString("tip-switchToAllPhotos", comment: "")
        let tipView = EasyTipView(text: switchToAllPhotos, preferences: preferences, delegate: self)
        tipView.show(forView: photos.navController.viewController.segmentedSlider.allLabel, withinSuperview: photos.navController.viewController.view)
        
        TipViews.starTipView1 = tipView
        TipViews.currentStarStep = 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            UIAccessibility.post(notification: .layoutChanged, argument: self.photos.navController.viewController.segmentedSlider)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                let stepText = AccessibilityText(text: "Step 1.", customPitch: 0.7)
                let instructions = AccessibilityText(text: "Swipe up on the slider to switch to All photos", isRaised: false)
                UIAccessibility.post(notification: .announcement, argument: UIAccessibility.makeAttributedText([stepText, instructions]))
            }
        }
    }
    
    func startStarThirdStep() {
        TipViews.dismissAll()
        
        var preferences = EasyTipView.globalPreferences
        preferences.drawing.backgroundColor = UIColor(named: "PopTipGold")!
        preferences.drawing.arrowPosition = .left
        
        preferences.drawing.shadowColor = #colorLiteral(red: 0.4207544327, green: 0.4207544327, blue: 0.4207544327, alpha: 1)
        preferences.drawing.shadowOpacity = 0.5
        preferences.drawing.shadowRadius = 2
        
        preferences.positioning.bubbleInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        preferences.positioning.contentInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 14)
        
        let tapToStarSelected = NSLocalizedString("tip-tapToStarSelected", comment: "")
        let tipView = EasyTipView(text: tapToStarSelected, preferences: preferences, delegate: self)
        tipView.show(forView: tabBarView.starButton)
        
        TipViews.starTipView3 = tipView
        TipViews.currentStarStep = 3
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            UIAccessibility.post(notification: .layoutChanged, argument: self.tabBarView.starButton)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                let stepText = AccessibilityText(text: "Step 3.", customPitch: 0.7)
                let instructions = AccessibilityText(text: "Double-tap Star button to star selected photos", isRaised: false)
                UIAccessibility.post(notification: .announcement, argument: UIAccessibility.makeAttributedText([stepText, instructions]))
            }
        }
    }
}
