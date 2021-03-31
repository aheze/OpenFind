//
//  PhotosVC+Tips.swift
//  Find
//
//  Created by Zheng on 1/27/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotosViewController {
    func startStarSecondStep() {
        TipViews.starTipView1?.dismiss()
        
        var preferences = EasyTipView.globalPreferences
        preferences.drawing.backgroundColor = UIColor(named: "PopTipGold")!
        preferences.drawing.arrowPosition = .bottom
        
        preferences.drawing.shadowColor = #colorLiteral(red: 0.4207544327, green: 0.4207544327, blue: 0.4207544327, alpha: 1)
        preferences.drawing.shadowOpacity = 0.5
        preferences.drawing.shadowRadius = 2
        
        preferences.positioning.bubbleInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        
        let tapSelect = NSLocalizedString("tip-tapSelect", comment: "")
        let tipView = EasyTipView(text: tapSelect, preferences: preferences, delegate: self)
        tipView.show(forItem: selectButton, withinSuperView: ViewControllerState.currentVC?.view)
        
        TipViews.starTipView2 = tipView
        TipViews.currentStarStep = 2
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            UIAccessibility.post(notification: .layoutChanged, argument: self.selectButton)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                let stepText = AccessibilityText(text: "Step 2.", customPitch: 0.7)
                let instructions = AccessibilityText(text: "Double-tap Select, then select the photos that you want to star.", isRaised: false)
                UIAccessibility.post(notification: .announcement, argument: UIAccessibility.makeAttributedText([stepText, instructions]))
            }
        }
    }
    func startCacheSecondStep() {
        TipViews.cacheTipView1?.dismiss()
        
        var preferences = EasyTipView.globalPreferences
        preferences.drawing.backgroundColor = UIColor(named: "PopTipLocal")!
        preferences.drawing.arrowPosition = .bottom
        
        preferences.drawing.shadowColor = #colorLiteral(red: 0.4207544327, green: 0.4207544327, blue: 0.4207544327, alpha: 1)
        preferences.drawing.shadowOpacity = 0.5
        preferences.drawing.shadowRadius = 2
        
        preferences.positioning.bubbleInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        
        let tapSelect = NSLocalizedString("tip-tapSelect", comment: "")
        
        let tipView = EasyTipView(text: tapSelect, preferences: preferences, delegate: self)
        tipView.show(forItem: selectButton, withinSuperView: ViewControllerState.currentVC?.view)
        
        TipViews.cacheTipView2 = tipView
        TipViews.currentCacheStep = 2
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            UIAccessibility.post(notification: .layoutChanged, argument: self.selectButton)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                let stepText = AccessibilityText(text: "Step 2.", customPitch: 0.7)
                let instructions = AccessibilityText(text: "Double-tap Select, then select the photos that you want to cache", isRaised: false)
                UIAccessibility.post(notification: .announcement, argument: UIAccessibility.makeAttributedText([stepText, instructions]))
            }
        }
    }
}
extension PhotosViewController: EasyTipViewDelegate {
    func easyTipViewDidTap(_ tipView: EasyTipView) {
        print("tapped")
    }
    
    func easyTipViewDidDismiss(_ tipView: EasyTipView) {
        if tipView == TipViews.starTipView2 || tipView == TipViews.cacheTipView2 {
            if TipViews.inTutorial {
                TipViews.finishTutorial()
            }
        }
    }
}
