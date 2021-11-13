//
//  Constants.swift
//  TabBarController
//
//  Created by Zheng on 10/28/21.
//

import SwiftUI

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

struct Constants {
    
    static var tabBarDarkBackgroundColor = UIColor(hex: 0x002F3B, alpha: 0.5)
    static var tabBarLightBackgroundColor = UIColor.systemBackground
    
    /// make the fade a bit faster
    static var tabBarToolbarAlphaMultiplier = CGFloat(3.5)
    
}

extension UIColor {
    convenience init(hex: UInt, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}
