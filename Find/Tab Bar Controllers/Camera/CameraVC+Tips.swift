//
//  CameraVC+Tips.swift
//  Find
//
//  Created by Zheng on 1/26/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension CameraViewController {
    func showCacheTip() {
        if !TipViews.inTutorial {
            var preferences = EasyTipView.globalPreferences
            preferences.drawing.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6)
            preferences.drawing.arrowPosition = .bottom
            if cacheTipView == nil, !dismissedCacheTipAlready {
                
                let cacheToGetMoreAccurateResults = NSLocalizedString("tip-cacheToGetMoreAccurateResults", comment: "")
                let tipView = EasyTipView(text: cacheToGetMoreAccurateResults, preferences: preferences, delegate: self)
                tipView.show(forView: cache)
                self.cacheTipView = tipView
            }
        }
    }
    
    func startLocalThirdStep() {
        TipViews.localTipView2?.dismiss()
        
        var preferences = EasyTipView.globalPreferences
        preferences.drawing.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6)
        preferences.drawing.arrowPosition = .bottom
        
        let tapHereToSave = NSLocalizedString("tip-tapHereToSave", comment: "")
        let tipView = EasyTipView(text: tapHereToSave, preferences: preferences, delegate: self)
        tipView.show(forView: saveToPhotos, withinSuperview: view)
        
        TipViews.localTipView3 = tipView
        TipViews.currentLocalStep = 3
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            UIAccessibility.post(notification: .layoutChanged, argument: self.saveToPhotos)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                let stepText = AccessibilityText(text: "Step 3.", customPitch: 0.7)
                let instructions = AccessibilityText(text: "Double-tap the Save to Photos button", isRaised: false)
                UIAccessibility.post(notification: .announcement, argument: UIAccessibility.makeAttributedText([stepText, instructions]))
            }
        }
        
    }
}

extension CameraViewController: EasyTipViewDelegate {
    func easyTipViewDidTap(_ tipView: EasyTipView) {
    }
    
    func easyTipViewDidDismiss(_ tipView: EasyTipView) {
        if tipView == cacheTipView {
            cacheTipView = nil
            dismissedCacheTipAlready = true
        }
        
        if tipView == TipViews.localTipView3 {
            TipViews.finishTutorial()
        }
    }
}
