//
//  CameraVC+Tips.swift
//  Find
//
//  Created by Zheng on 1/26/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import EasyTipView

extension CameraViewController {
    func showCacheTip() {
        var preferences = EasyTipView.globalPreferences
        preferences.drawing.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6)
        preferences.drawing.arrowPosition = .bottom
        print("cache tip view is: \(cacheTipView), dismmised befroe: \(dismissedCacheTipAlready)")
        if cacheTipView == nil, !dismissedCacheTipAlready {
            let tipView = EasyTipView(text: "Cache to get more accurate results", preferences: preferences, delegate: self)
            tipView.show(forView: cache)
            self.cacheTipView = tipView
        }
    }
}

extension CameraViewController: EasyTipViewDelegate {
    func easyTipViewDidTap(_ tipView: EasyTipView) {
        print("tapped")
    }
    
    func easyTipViewDidDismiss(_ tipView: EasyTipView) {
        print("dismissed")
        if tipView == cacheTipView {
            cacheTipView = nil
            dismissedCacheTipAlready = true
        }
    }
}
