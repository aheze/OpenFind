//
//  Constants.swift
//  Find
//
//  Created by Zheng on 11/18/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

enum Colors {
    /// Main accent color (blue)
    static var accent = UIColor(named: "Accent")!
    static var accentDarkBackground = UIColor(hex: 0x0052a9)
    static var activeIconColor = UIColor(hex: 0x8AF9FF)
}

extension Color {
    /// Main accent color (blue)
    static var accent = Colors.accent.color
    static var accentDarkBackground = Colors.accentDarkBackground.color
    static var activeIconColor = Colors.activeIconColor.color
}

enum Constants {
    
    static var iconFont = UIFont.preferredFont(forTextStyle: .title2)
    
    static var tabBarDarkBackgroundColor = UIColor(hex: 0x002F3B, alpha: 0.5)
    static var tabBarLightBackgroundColor = UIColor.systemBackground
    
    /// make the fade a bit faster
    static var tabBarToolbarAlphaMultiplier = CGFloat(3.5)
    
    /// how long until scale back
    static var toolbarIconDeactivateAnimationDelay = CGFloat(0.08)
    
    /// scale back speed
    static var toolbarIconDeactivateAnimationSpeed = CGFloat(0.3)
    
    
    /**
     For toolbars above the keyboard.
     when the on-screen keyboard is hidden (connected to external keyboard), it has a height of around 135 (less than 200)
     so in this case make the toolbar taller to get past the safe area.
     */
    static var minimumKeyboardHeight = CGFloat(200)
    
    static var tabBlurEffect = UIBlurEffect(style: .regular)
}

enum ConstantVars {
    /// default tab bar content height
    static let tabBarContentHeight = CGFloat(49)
    
    /// let icons overflow down a bit
    static var tabBarOverflowingIconsBottomPadding = CGFloat(0)
    
    /// light background height
    static var tabBarTotalHeight = CGFloat(0)
    
    /// dark background (camera) height
    static var tabBarTotalHeightExpanded = CGFloat(0)
    
    /// space under the Photos/Lists toolbars
    static var toolbarBottomPadding = CGFloat(0)
    
    static var tabBarOverflowingIconsBottomPaddingLandscape = CGFloat(0)
    static var tabBarTotalHeightLandscape = CGFloat(0)
    static var tabBarTotalHeightExpandedLandscape = CGFloat(0)
    static var toolbarBottomPaddingLandscape = CGFloat(0)
    
    static func configure(window: UIWindow?) {
        let safeAreaInsets = window?.safeAreaInsets ?? .zero
        let orientation = UIWindow.currentInterfaceOrientation ?? .portrait
        
        let bottomSafeAreaInset: CGFloat /// bottom inset for the physical device
        let deviceHasNotch: Bool
        if orientation.isLandscape {
            deviceHasNotch = safeAreaInsets.left > 0 || safeAreaInsets.right > 0
        } else {
            deviceHasNotch = safeAreaInsets.bottom > 0
        }
        
        switch orientation {
        case .portrait:
            bottomSafeAreaInset = safeAreaInsets.bottom
        case .portraitUpsideDown:
            bottomSafeAreaInset = safeAreaInsets.bottom
        case .landscapeLeft: /// home button left
            bottomSafeAreaInset = safeAreaInsets.left
        case .landscapeRight: /// home button right
            bottomSafeAreaInset = safeAreaInsets.right
        default:
            bottomSafeAreaInset = 0
        }
        
        if deviceHasNotch {
            let bottomPadding = bottomSafeAreaInset + 4
            toolbarBottomPadding = bottomPadding
            tabBarOverflowingIconsBottomPadding = bottomPadding - 6 /// make the icons move up, but not that much
            tabBarTotalHeight = tabBarContentHeight + bottomPadding
            tabBarTotalHeightExpanded = tabBarTotalHeight + 58 /// 58 works out pretty good
            
            toolbarBottomPaddingLandscape = bottomSafeAreaInset
            tabBarOverflowingIconsBottomPaddingLandscape = bottomSafeAreaInset - 6
            tabBarTotalHeightLandscape = tabBarContentHeight + bottomSafeAreaInset
            tabBarTotalHeightExpandedLandscape = tabBarTotalHeightLandscape
            
        } else {
            toolbarBottomPadding = bottomSafeAreaInset
            tabBarOverflowingIconsBottomPadding = bottomSafeAreaInset
            tabBarTotalHeight = tabBarContentHeight
            tabBarTotalHeightExpanded = tabBarTotalHeight + 58
            
            toolbarBottomPaddingLandscape = toolbarBottomPadding
            tabBarOverflowingIconsBottomPaddingLandscape = tabBarOverflowingIconsBottomPadding
            tabBarTotalHeightLandscape = tabBarTotalHeight
            tabBarTotalHeightExpandedLandscape = tabBarTotalHeight
        }
    }
}
