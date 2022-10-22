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
    
    static var queuingStar = false
    static var queuingCache = false
    static var removeStarFilterView: EasyTipView?
    static var removeCacheFilterView: EasyTipView?
    
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
        
        dismissAll()
        
        currentLocalStep = 0
        currentStarStep = 0
        currentCacheStep = 0
        
        queuingStar = false
        queuingCache = false
        
        resetToBeginning?()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            UIAccessibility.post(notification: .announcement, argument: "Tutorial complete.")
        }
    }
    
    static func dismissAll() {
        localTipView1?.dismiss()
        localTipView2?.dismiss()
        localTipView3?.dismiss()
        removeStarFilterView?.dismiss()
        starTipView1?.dismiss()
        starTipView2?.dismiss()
        starTipView3?.dismiss()
        removeCacheFilterView?.dismiss()
        cacheTipView1?.dismiss()
        cacheTipView2?.dismiss()
        cacheTipView3?.dismiss()
    }
    
    static var resetToBeginning: (() -> Void)? /// change empty view back to beginning
}

extension ViewController: EasyTipViewDelegate {
    func easyTipViewDidTap(_ tipView: EasyTipView) {}
    
    func easyTipViewDidDismiss(_ tipView: EasyTipView) {
        if
            tipView == TipViews.localTipView1 ||
            tipView == TipViews.localTipView2 ||
            tipView == TipViews.starTipView1 ||
            tipView == TipViews.starTipView3 ||
            tipView == TipViews.cacheTipView1 ||
            tipView == TipViews.cacheTipView3
        {
            if TipViews.inTutorial {
                TipViews.finishTutorial()
            }
        }
    }
}
