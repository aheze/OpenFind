//
//  Constants.swift
//  Find
//
//  Created by Zheng on 11/18/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

public enum Constants {
    public static var activeIconColor = UIColor(hex: 0x8AF9FF)
    public static var iconFont = UIFont.preferredFont(forTextStyle: .title2)
    
    static var darkBlueBackground = UIColor(hex: 0x006186)
    
    static var tabBarDarkBackgroundColor = UIColor(hex: 0x002F3B, alpha: 0.5)
    static var tabBarLightBackgroundColor = UIColor.systemBackground
    
    /// make the fade a bit faster
    static var tabBarToolbarAlphaMultiplier = CGFloat(3.5)
}

public struct ConstantVars {
    
    /// default tab bar content height
    static let tabBarContentHeight = CGFloat(49)
    
    /// space under hugging tab bar icons
    static var tabBarHuggingBottomPadding = CGFloat(0)
    
    /// let icons overflow down a bit
    static var tabBarOverflowingIconsBottomPadding = CGFloat(0)
    
    /// light background height
    static var tabBarTotalHeight = CGFloat(0)
    
    /// dark background (camera) height
    static var tabBarTotalHeightExpanded = CGFloat(0)
    
    public static func configure(window: UIWindow?) {
        let bottomSafeAreaInset = window?.safeAreaInsets.bottom ?? 0
        let deviceHasNotch = bottomSafeAreaInset > 0
        
        if deviceHasNotch {
            tabBarHuggingBottomPadding = bottomSafeAreaInset
            tabBarOverflowingIconsBottomPadding = bottomSafeAreaInset - 6
            tabBarTotalHeight = tabBarContentHeight + bottomSafeAreaInset
            tabBarTotalHeightExpanded = tabBarTotalHeight + 58 /// 58 works out pretty good
        } else {
            tabBarHuggingBottomPadding = bottomSafeAreaInset
            tabBarOverflowingIconsBottomPadding = bottomSafeAreaInset
            tabBarTotalHeight = tabBarContentHeight
            tabBarTotalHeightExpanded = tabBarTotalHeight + 58
        }
    }
}



