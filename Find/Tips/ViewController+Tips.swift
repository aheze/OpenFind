//
//  ViewController+Tips.swift
//  Find
//
//  Created by Zheng on 1/26/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

struct TipViews {
    static var inTutorial = false
    
    static var localTipView1: EasyTipView?
    static var localTipView2: EasyTipView?
    static var localTipView3: EasyTipView?
    static var currentLocalStep = 0 /// what step currently on
    
    static var starTipView1: EasyTipView?
    static var starTipView2: EasyTipView?
    static var starTipView3: EasyTipView?
    static var currentStarStep = 0 /// what step currently on
    
    static var cacheTipView1: EasyTipView?
    static var cacheTipView2: EasyTipView?
    static var cacheTipView3: EasyTipView?
    static var currentCacheStep = 0 /// what step currently on
    
    static func finishTutorial() {
        inTutorial = false
        
        localTipView1?.dismiss()
        localTipView2?.dismiss()
        localTipView3?.dismiss()
        starTipView1?.dismiss()
        starTipView2?.dismiss()
        starTipView3?.dismiss()
        cacheTipView1?.dismiss()
        cacheTipView2?.dismiss()
        cacheTipView3?.dismiss()
        
        currentLocalStep = 0
        currentStarStep = 0
        currentCacheStep = 0
        
        resetToBeginning?()
    }
    
    static var resetToBeginning: (() -> Void)? /// change empty view back to beginning
}
extension ViewController {
    func configurePreferences() {
        
        var preferences = EasyTipView.Preferences()
        preferences.drawing.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        preferences.drawing.foregroundColor = UIColor.white
        preferences.drawing.backgroundColor = UIColor.secondaryLabel
        preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.top
        
        preferences.drawing.arrowWidth = 12
        preferences.drawing.arrowHeight = 6
        preferences.drawing.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6)
        preferences.positioning.bubbleInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        preferences.animating.dismissTransform = CGAffineTransform(translationX: 0, y: -6).scaledBy(x: 0.6, y: 0.6)
        
        EasyTipView.globalPreferences = preferences
    }
}

extension ViewController: EasyTipViewDelegate {
    func easyTipViewDidTap(_ tipView: EasyTipView) {
        print("tapped")
    }
    
    func easyTipViewDidDismiss(_ tipView: EasyTipView) {
        print("dismissed")
        if
            tipView == TipViews.localTipView1 ||
                tipView == TipViews.localTipView2 ||
                tipView == TipViews.starTipView1 ||
                tipView == TipViews.starTipView3 ||
                tipView == TipViews.cacheTipView1 ||
                tipView == TipViews.cacheTipView3 {
            print("yes, dismiss")
            if TipViews.inTutorial {
                TipViews.finishTutorial()
            }
        }
    }
}
