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
        var preferences = Constants.preferences
        preferences.drawing.arrowPosition = .bottom
        preferences.drawing.arrowWidth = 12
        preferences.drawing.arrowHeight = 6
        preferences.drawing.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6)
        preferences.positioning.bubbleInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        
        preferences.animating.dismissTransform = CGAffineTransform(translationX: 0, y: -6).scaledBy(x: 0.6, y: 0.6)
        
        let tipView = EasyTipView(text: "Cache to get more accurate results", preferences: preferences, delegate: self)
        tipView.show(forView: cache)
        self.cacheTipView = tipView
    }
}

extension CameraViewController: EasyTipViewDelegate {
    func easyTipViewDidTap(_ tipView: EasyTipView) {
        print("tapped")
    }
    
    func easyTipViewDidDismiss(_ tipView: EasyTipView) {
        print("dismissed")
    }
}
