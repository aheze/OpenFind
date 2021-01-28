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
        
        let tipView = EasyTipView(text: "Tap Select", preferences: preferences, delegate: self)
//        tipView.show(forItem: selectButton, withinSuperview: view)
        tipView.show(forItem: selectButton, withinSuperView: ViewControllerState.currentVC?.view)
        
        TipViews.starTipView2 = tipView
        TipViews.currentStarStep = 2
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
        
        let tipView = EasyTipView(text: "Tap Select", preferences: preferences, delegate: self)
        tipView.show(forItem: selectButton, withinSuperView: ViewControllerState.currentVC?.view)
        
        TipViews.cacheTipView2 = tipView
        TipViews.currentCacheStep = 2
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
