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
        
        Constants.preferences.drawing.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        Constants.preferences.drawing.foregroundColor = UIColor.white
        Constants.preferences.drawing.backgroundColor = UIColor.secondaryLabel
        Constants.preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.top

        /*
         * Optionally you can make these preferences global for all future EasyTipViews
         */
//        EasyTipView.globalPreferences = preferences
    }
}
