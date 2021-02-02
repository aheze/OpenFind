//
//  VC+CacheTip.swift
//  Find
//
//  Created by Zheng on 1/27/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension ViewController {
    func startCacheTutorial() {
        TipViews.inTutorial = true
        
        var preferences = EasyTipView.globalPreferences
        preferences.drawing.backgroundColor = UIColor(named: "PopTipLocal")!
        preferences.drawing.arrowPosition = .bottom
        
        preferences.drawing.shadowColor = #colorLiteral(red: 0.4207544327, green: 0.4207544327, blue: 0.4207544327, alpha: 1)
        preferences.drawing.shadowOpacity = 0.5
        preferences.drawing.shadowRadius = 2
        
        preferences.positioning.bubbleInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        
        let switchToAllPhotos = NSLocalizedString("tip-switchToAllPhotos", comment: "")
        let tipView = EasyTipView(text: switchToAllPhotos, preferences: preferences, delegate: self)
        tipView.show(forView: photos.navController.viewController.segmentedSlider.allLabel, withinSuperview: photos.navController.viewController.view)
        
        TipViews.cacheTipView1 = tipView
        TipViews.currentCacheStep = 1
    }
    func startCacheThirdStep() {
        TipViews.cacheTipView2?.dismiss()
        
        var preferences = EasyTipView.globalPreferences
        preferences.drawing.backgroundColor = UIColor(named: "PopTipLocal")!
        preferences.drawing.arrowPosition = .left
        
        preferences.drawing.shadowColor = #colorLiteral(red: 0.4207544327, green: 0.4207544327, blue: 0.4207544327, alpha: 1)
        preferences.drawing.shadowOpacity = 0.5
        preferences.drawing.shadowRadius = 2
        
        preferences.positioning.bubbleInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        preferences.positioning.contentInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 14)
        
        let tapToCacheSelected = NSLocalizedString("tip-tapToCacheSelected", comment: "")
        let tipView = EasyTipView(text: tapToCacheSelected, preferences: preferences, delegate: self)
        tipView.show(forView: tabBarView.cacheButton)
        
        TipViews.cacheTipView3 = tipView
        TipViews.currentStarStep = 3
    }
}
