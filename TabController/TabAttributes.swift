//
//  TabAttributes.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/30/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import SwiftUI

/**
 attributes which can have an intermediate value
 */
protocol AnimatableAttributes {
    init(progress: CGFloat, from fromAttributes: Self, to toAttributes: Self)
}

enum AnimatableUtilities {
    static func mixedValue(from: CGFloat, to: CGFloat, progress: CGFloat) -> CGFloat {
        let value = from + (to - from) * progress
        return value
    }

    static func mixedValue(from: CGPoint, to: CGPoint, progress: CGFloat) -> CGPoint {
        let valueX = from.x + (to.x - from.x) * progress
        let valueY = from.y + (to.y - from.y) * progress
        return CGPoint(x: valueX, y: valueY)
    }
}

struct TabBarAttributes: AnimatableAttributes {
    /// color of the tab bar
    var backgroundColor: UIColor
    
    /// height of the visual background
    var backgroundHeight: CGFloat
    
    /// top padding of everything inside the tab bar
    var topPadding: CGFloat
    
    /// how much y offset for the camera toolbar
    var toolbarOffset: CGFloat
    
    /// **Note!** fade out quicker than swipe
    var toolbarAlpha: CGFloat
    
    /// alpha of the top divider line
    var topLineAlpha: CGFloat
    
    var iconsBottomPaddingForOverflow: CGFloat
    
    var toolbarBottomPadding: CGFloat
    
    static let lightBackground: Self = .init(
        backgroundColor: Constants.tabBarLightBackgroundColor,
        backgroundHeight: ConstantVars.tabBarTotalHeight,
        topPadding: 0,
        toolbarOffset: -40,
        toolbarAlpha: 0,
        topLineAlpha: 1,
        iconsBottomPaddingForOverflow: ConstantVars.tabBarOverflowingIconsBottomPadding,
        toolbarBottomPadding: ConstantVars.toolbarBottomPadding
    )
    
    static let lightBackgroundLandscape: Self = .init(
        backgroundColor: Constants.tabBarLightBackgroundColor,
        backgroundHeight: ConstantVars.tabBarTotalHeightLandscape,
        topPadding: 0,
        toolbarOffset: -40,
        toolbarAlpha: 0,
        topLineAlpha: 1,
        iconsBottomPaddingForOverflow: ConstantVars.tabBarOverflowingIconsBottomPaddingLandscape,
        toolbarBottomPadding: ConstantVars.toolbarBottomPaddingLandscape
    )
    
    /// when active tab is camera
    static let darkBackground: Self = .init(
        backgroundColor: Constants.tabBarDarkBackgroundColor,
        backgroundHeight: ConstantVars.tabBarTotalHeightExpanded,
        topPadding: 16,
        toolbarOffset: 0,
        toolbarAlpha: 1,
        topLineAlpha: 0,
        iconsBottomPaddingForOverflow: ConstantVars.tabBarOverflowingIconsBottomPadding,
        toolbarBottomPadding: ConstantVars.toolbarBottomPadding
    )
    
    static let darkBackgroundLandscape: Self = .init(
        backgroundColor: Constants.tabBarDarkBackgroundColor,
        backgroundHeight: ConstantVars.tabBarTotalHeightExpandedLandscape,
        topPadding: 0,
        toolbarOffset: -40,
        toolbarAlpha: 0,
        topLineAlpha: 0,
        iconsBottomPaddingForOverflow: ConstantVars.tabBarOverflowingIconsBottomPaddingLandscape,
        toolbarBottomPadding: ConstantVars.toolbarBottomPaddingLandscape
    )
}

/// keep normal initializer, so put in extension
extension TabBarAttributes {
    init(progress: CGFloat, from fromAttributes: TabBarAttributes, to toAttributes: TabBarAttributes) {
        let backgroundColor = fromAttributes.backgroundColor.toColor(toAttributes.backgroundColor, percentage: progress)
        let backgroundHeight = max(
            ConstantVars.tabBarTotalHeight,
            AnimatableUtilities.mixedValue(from: fromAttributes.backgroundHeight, to: toAttributes.backgroundHeight, progress: progress)
        )
        
        let topPadding = AnimatableUtilities.mixedValue(from: fromAttributes.topPadding, to: toAttributes.topPadding, progress: progress)
        
        let toolbarOffset = AnimatableUtilities.mixedValue(from: fromAttributes.toolbarOffset, to: toAttributes.toolbarOffset, progress: progress)
        
        /// move a bit faster for the toolbar
        let fasterProgress = min(1, progress * Constants.tabBarToolbarAlphaMultiplier)
        let toolbarAlpha = AnimatableUtilities.mixedValue(from: fromAttributes.toolbarAlpha, to: toAttributes.toolbarAlpha, progress: fasterProgress)
        let topLineAlpha = AnimatableUtilities.mixedValue(from: fromAttributes.topLineAlpha, to: toAttributes.topLineAlpha, progress: progress)
        
        let iconsBottomPaddingForOverflow = AnimatableUtilities.mixedValue(from: fromAttributes.iconsBottomPaddingForOverflow, to: toAttributes.iconsBottomPaddingForOverflow, progress: progress)
        let toolbarBottomPadding = AnimatableUtilities.mixedValue(from: fromAttributes.toolbarBottomPadding, to: toAttributes.toolbarBottomPadding, progress: progress)
        
        self.backgroundColor = backgroundColor
        self.backgroundHeight = backgroundHeight
        self.topPadding = topPadding
        self.toolbarOffset = toolbarOffset
        self.toolbarAlpha = toolbarAlpha
        self.topLineAlpha = topLineAlpha
        self.iconsBottomPaddingForOverflow = iconsBottomPaddingForOverflow
        self.toolbarBottomPadding = toolbarBottomPadding
    }
}

struct PhotosIconAttributes: AnimatableAttributes {
    var foregroundColor: UIColor
    var backgroundHeight: CGFloat
    
    /// when active tab is camera
    static let inactiveDarkBackground: Self = { /// `Self` could also be `PhotosIconAttributes`
        .init(
            foregroundColor: UIColor.white,
            backgroundHeight: 48
        )
    }()
    
    static let inactiveLightBackground: Self = .init(
        foregroundColor: UIColor(hex: 0x7E7E7E),
        backgroundHeight: 48
    )
    
    /// always light background
    static let active: Self = .init(
        foregroundColor: UIColor(hex: 0x40C74D),
        backgroundHeight: 48
    )
}

/// keep normal initializer, so put in extension
extension PhotosIconAttributes {
    init(progress: CGFloat, from fromAttributes: Self, to toAttributes: Self) {
        let foregroundColor = fromAttributes.foregroundColor.toColor(toAttributes.foregroundColor, percentage: progress)
        let backgroundHeight = fromAttributes.backgroundHeight + (toAttributes.backgroundHeight - fromAttributes.backgroundHeight) * progress
        
        self.foregroundColor = foregroundColor
        self.backgroundHeight = backgroundHeight
    }
}

struct CameraIconAttributes: AnimatableAttributes {
    /// fill color
    var foregroundColor: UIColor
    
    /// entire background height
    var backgroundHeight: CGFloat
    
    /// length of circle
    var length: CGFloat
    
    /// rim color
    var rimColor: UIColor
    
    /// rim width
    var rimWidth: CGFloat
    
    static let inactive: Self = .init(
        foregroundColor: UIColor(hex: 0x7E7E7E).withAlphaComponent(0.5),
        backgroundHeight: 48,
        length: 26,
        rimColor: UIColor(hex: 0x7E7E7E),
        rimWidth: 1
    )
    
    static let active: Self = .init(
        foregroundColor: UIColor(hex: 0x00AEEF).withAlphaComponent(0.5),
        backgroundHeight: 98,
        length: 64,
        rimColor: .white,
        rimWidth: 3
    )
    
    static let activeLandscape: Self = .init(
        foregroundColor: UIColor.white.withAlphaComponent(0.5),
        backgroundHeight: 48,
        length: 26,
        rimColor: .white,
        rimWidth: 1
    )
}

extension CameraIconAttributes {
    init(progress: CGFloat, from fromAttributes: Self, to toAttributes: Self) {
        let foregroundColor = fromAttributes.foregroundColor.toColor(toAttributes.foregroundColor, percentage: progress)
        let backgroundHeight = fromAttributes.backgroundHeight + (toAttributes.backgroundHeight - fromAttributes.backgroundHeight) * progress
        let length = fromAttributes.length + (toAttributes.length - fromAttributes.length) * progress
        let rimColor = fromAttributes.rimColor.toColor(toAttributes.rimColor, percentage: progress)
        let rimWidth = fromAttributes.rimWidth + (toAttributes.rimWidth - fromAttributes.rimWidth) * progress
        
        self.foregroundColor = foregroundColor
        self.backgroundHeight = backgroundHeight
        self.length = length
        self.rimColor = rimColor
        self.rimWidth = rimWidth
    }
}

struct ListsIconAttributes: AnimatableAttributes {
    var foregroundColor: UIColor
    var backgroundHeight: CGFloat
    
    static let inactiveDarkBackground: ListsIconAttributes = .init(
        foregroundColor: UIColor.white,
        backgroundHeight: 48
    )
    
    static let inactiveLightBackground: ListsIconAttributes = .init(
        foregroundColor: UIColor(hex: 0x7E7E7E),
        backgroundHeight: 48
    )
    
    static let active: ListsIconAttributes = .init(
        foregroundColor: UIColor(hex: 0xFFC600),
        backgroundHeight: 48
    )
}

/// keep normal initializer, so put in extension
extension ListsIconAttributes {
    init(progress: CGFloat, from fromAttributes: ListsIconAttributes, to toAttributes: ListsIconAttributes) {
        let foregroundColor = fromAttributes.foregroundColor.toColor(toAttributes.foregroundColor, percentage: progress)
        let backgroundHeight = fromAttributes.backgroundHeight + (toAttributes.backgroundHeight - fromAttributes.backgroundHeight) * progress
        
        self.foregroundColor = foregroundColor
        self.backgroundHeight = backgroundHeight
    }
}
