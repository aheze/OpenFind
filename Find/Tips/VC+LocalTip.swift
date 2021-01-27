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
        preferences.drawing.backgroundColor = UIColor(named: "100Blue")!
        preferences.drawing.arrowPosition = .bottom
        
        preferences.drawing.shadowColor = #colorLiteral(red: 0.4207544327, green: 0.4207544327, blue: 0.4207544327, alpha: 1)
        preferences.drawing.shadowOpacity = 0.5
        preferences.drawing.shadowRadius = 2
        let tipView = EasyTipView(text: "Go to camera", preferences: preferences, delegate: self)
        tipView.show(forView: tabBarView.cameraIcon)
        
        TipViews.localTipView1 = tipView
        TipViews.currentLocalStep = 1
    }
    func startLocalSecondStep() {
        TipViews.localTipView1?.dismiss()
        
        var preferences = EasyTipView.globalPreferences
        preferences.drawing.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6)
        preferences.drawing.arrowPosition = .bottom
        let tipView = EasyTipView(text: "Pause the preview", preferences: preferences, delegate: self)
        tipView.show(forView: camera.cameraIconHolder)
        
        
        TipViews.localTipView2 = tipView
        TipViews.currentLocalStep = 2
    }
}
