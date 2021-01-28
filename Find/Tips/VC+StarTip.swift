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
        TipViews.inTutorial = true
        
        var preferences = EasyTipView.globalPreferences
        preferences.drawing.backgroundColor = UIColor(named: "PopTipGold")!
        preferences.drawing.arrowPosition = .bottom
        
        preferences.drawing.shadowColor = #colorLiteral(red: 0.4207544327, green: 0.4207544327, blue: 0.4207544327, alpha: 1)
        preferences.drawing.shadowOpacity = 0.5
        preferences.drawing.shadowRadius = 2
        
        preferences.positioning.bubbleInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        
        let tipView = EasyTipView(text: "Switch to All Photos", preferences: preferences, delegate: self)
        tipView.show(forView: photos.navController.viewController.segmentedSlider.allLabel, withinSuperview: photos.navController.viewController.view)
        
        TipViews.starTipView1 = tipView
        TipViews.currentStarStep = 1
    }
    func startStarThirdStep() {
        TipViews.starTipView2?.dismiss()
        
        var preferences = EasyTipView.globalPreferences
        preferences.drawing.backgroundColor = UIColor(named: "PopTipGold")!
        preferences.drawing.arrowPosition = .left
        
        preferences.drawing.shadowColor = #colorLiteral(red: 0.4207544327, green: 0.4207544327, blue: 0.4207544327, alpha: 1)
        preferences.drawing.shadowOpacity = 0.5
        preferences.drawing.shadowRadius = 2
        
        preferences.positioning.bubbleInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        preferences.positioning.contentInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 14)
        
        let tipView = EasyTipView(text: "Tap to star selected photos", preferences: preferences, delegate: self)
        tipView.show(forView: tabBarView.starButton)
        
        TipViews.starTipView3 = tipView
        TipViews.currentStarStep = 3
    }
}
