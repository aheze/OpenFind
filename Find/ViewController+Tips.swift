//
//  ViewController+Tips.swift
//  Find
//
//  Created by Zheng on 1/26/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import EasyTipView

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
        
        /*
         * Optionally you can make these preferences global for all future EasyTipViews
         */
        EasyTipView.globalPreferences = preferences
    }
}
