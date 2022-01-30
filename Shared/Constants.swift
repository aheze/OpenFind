//
//  Constants.swift
//  Find
//
//  Created by Zheng on 11/18/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

enum Constants {
    static var activeIconColor = UIColor(hex: 0x8AF9FF)
    static var iconFont = UIFont.preferredFont(forTextStyle: .title2)
    
    static var darkBlueBackground = UIColor(hex: 0x006186)
    
    static var tabBarDarkBackgroundColor = UIColor(hex: 0x002F3B, alpha: 0.5)
    static var tabBarLightBackgroundColor = UIColor.systemBackground
    
    /// make the fade a bit faster
    static var tabBarToolbarAlphaMultiplier = CGFloat(3.5)
    
    /// how long until scale back
    static var toolbarIconDeactivateAnimationDelay = CGFloat(0.08)
    
    /// scale back speed
    static var toolbarIconDeactivateAnimationSpeed = CGFloat(0.3)
    
    static var defaultHighlightColor = UIColor(hex: 0x00AEEF)
}

enum ConstantVars {
    /// default tab bar content height
    static let tabBarContentHeight = CGFloat(49)
    
    /// space under the Photos/Lists toolbars
    static var toolbarBottomPadding = CGFloat(0)
    
    /// let icons overflow down a bit
    static var tabBarOverflowingIconsBottomPadding = CGFloat(0)
    
    /// light background height
    static var tabBarTotalHeight = CGFloat(0)
    
    /// dark background (camera) height
    static var tabBarTotalHeightExpanded = CGFloat(0)
    
    
    static var toolbarBottomPaddingLandscape = CGFloat(0)
    static var tabBarOverflowingIconsBottomPaddingLandscape = CGFloat(0)
    static var tabBarTotalHeightLandscape = CGFloat(0)
    static var tabBarTotalHeightExpandedLandscape = CGFloat(0)
    
    static func configure(window: UIWindow?) {
        let bottomSafeAreaInset = window?.safeAreaInsets.bottom ?? 0
        let deviceHasNotch = bottomSafeAreaInset > 0
        
        if deviceHasNotch {
            let bottomPadding = bottomSafeAreaInset + 3
            toolbarBottomPadding = bottomPadding
            tabBarOverflowingIconsBottomPadding = bottomPadding - 6 /// make the icons move up, but not that much
            tabBarTotalHeight = tabBarContentHeight + bottomPadding
            tabBarTotalHeightExpanded = tabBarTotalHeight + 58 /// 58 works out pretty good
            
            toolbarBottomPaddingLandscape = bottomSafeAreaInset
            tabBarOverflowingIconsBottomPaddingLandscape = bottomSafeAreaInset - 6
            tabBarTotalHeightLandscape = bottomSafeAreaInset
            tabBarTotalHeightExpandedLandscape = bottomSafeAreaInset + 58
            
        } else {
            toolbarBottomPadding = bottomSafeAreaInset
            tabBarOverflowingIconsBottomPadding = bottomSafeAreaInset
            tabBarTotalHeight = tabBarContentHeight
            tabBarTotalHeightExpanded = tabBarTotalHeight + 58
            
            toolbarBottomPaddingLandscape = toolbarBottomPadding
            tabBarOverflowingIconsBottomPaddingLandscape = tabBarOverflowingIconsBottomPadding
            tabBarTotalHeightLandscape = tabBarTotalHeight
            tabBarTotalHeightExpandedLandscape = tabBarTotalHeightExpanded
        }
    }
}
