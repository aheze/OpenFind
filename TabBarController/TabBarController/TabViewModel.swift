//
//  TabViewModel.swift
//  TabBarController
//
//  Created by Zheng on 10/30/21.
//

import SwiftUI

class TabViewModel: ObservableObject {
    @Published var tabState: TabState = TabState.camera {
        didSet {
            tabBarAttributes = tabState.tabBarAttributes()
            photosIconAttributes = tabState.photosIconAttributes()
            cameraIconAttributes = tabState.cameraIconAttributes()
            listsIconAttributes = tabState.listsIconAttributes()
            animatorProgress = tabState.getAnimatorProgress()
        }
    }
    @Published var tabBarAttributes = TabBarAttributes.darkBackground
    @Published var photosIconAttributes = PhotosIconAttributes.inactiveDarkBackground
    @Published var cameraIconAttributes = CameraIconAttributes.active
    @Published var listsIconAttributes = ListsIconAttributes.inactiveDarkBackground
    @Published var animatorProgress = CGFloat(0) /// for blur
}

public enum TabState: Equatable {
    case photos
    case camera
    case lists
    case cameraToPhotos(CGFloat) /// associatedValue is the percentage
    case cameraToLists(CGFloat)
    
    var index: Int {
        switch self {
        case .photos:
            return 0
        case .camera:
            return 1
        case .lists:
            return 2
        case .cameraToPhotos(_):
            return 1
        case .cameraToLists(_):
            return 1
        }
    }
    var name: String {
        switch self {
        case .photos:
            return "Photos"
        case .camera:
            return "Camera"
        case .lists:
            return "Lists"
        case .cameraToPhotos(_):
            return ""
        case .cameraToLists(_):
            return ""
        }
    }
    func getAnimatorProgress() -> CGFloat {
        switch self {
        case .photos:
            return 1
        case .camera:
            return 0
        case .lists:
            return 1
        case .cameraToPhotos(let transitionProgress):
            return transitionProgress
        case .cameraToLists(let transitionProgress):
            return transitionProgress
        }
    }
    func tabBarAttributes() -> TabBarAttributes {
        switch self {
        case .photos:
            return .lightBackground
        case .camera:
            return .darkBackground
        case .lists:
            return .lightBackground
        case .cameraToPhotos(let transitionProgress):
            return .init(progress: transitionProgress, from: .darkBackground, to: .lightBackground)
        case .cameraToLists(let transitionProgress):
            return .init(progress: transitionProgress, from: .darkBackground, to: .lightBackground)
        }
    }
    func photosIconAttributes() -> PhotosIconAttributes {
        switch self {
        case .photos:
            return .active
        case .camera:
            return .inactiveDarkBackground
        case .lists:
            return .inactiveLightBackground
        case .cameraToPhotos(let transitionProgress):
            return .init(progress: transitionProgress, from: .inactiveDarkBackground, to: .active)
        case .cameraToLists(let transitionProgress):
            return .init(progress: transitionProgress, from: .inactiveDarkBackground, to: .inactiveLightBackground)
        }
    }
    func cameraIconAttributes() -> CameraIconAttributes {
        switch self {
        case .photos:
            return .inactive
        case .camera:
            return .active
        case .lists:
            return .inactive
        case .cameraToPhotos(let transitionProgress):
            
            /// camera is opposite (camera to photos, so need to reverse)
            let cameraProgress = max(0, 1 - transitionProgress)
            return .init(progress: cameraProgress, from: .inactive, to: .active)
        case .cameraToLists(let transitionProgress):
            let cameraProgress = max(0, 1 - transitionProgress)
            return .init(progress: cameraProgress, from: .inactive, to: .active)
        }
    }
    func listsIconAttributes() -> ListsIconAttributes {
        switch self {
        case .photos:
            return .inactiveLightBackground
        case .camera:
            return .inactiveDarkBackground
        case .lists:
            return .active
        case .cameraToPhotos(let transitionProgress):
            return .init(progress: transitionProgress, from: .inactiveDarkBackground, to: .inactiveLightBackground)
        case .cameraToLists(let transitionProgress):
            return .init(progress: transitionProgress, from: .inactiveDarkBackground, to: .active)
        }
    }
    
}

/**
 attributes which can have an intermediate value
 */
protocol AnimatableAttributes {
    init(progress: CGFloat, from fromAttributes: Self, to toAttributes: Self)
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
    
    static let lightBackground: Self = {
        return .init(
            backgroundColor: Constants.tabBarLightBackgroundColor,
            backgroundHeight: ConstantVars.tabBarTotalHeight,
            topPadding: 0,
            toolbarOffset: -40,
            toolbarAlpha: 0,
            topLineAlpha: 1
        )
    }()
    
    /// when active tab is camera
    static let darkBackground: Self = {
        return .init(
            backgroundColor: Constants.tabBarDarkBackgroundColor,
            backgroundHeight: ConstantVars.tabBarTotalHeightExpanded,
            topPadding: 16,
            toolbarOffset: 0,
            toolbarAlpha: 1,
            topLineAlpha: 0
        )
    }()
}

/// keep normal initializer, so put in extension
extension TabBarAttributes {
    init(progress: CGFloat, from fromAttributes: TabBarAttributes, to toAttributes: TabBarAttributes) {
        let backgroundColor = fromAttributes.backgroundColor.toColor(toAttributes.backgroundColor, percentage: progress)
        let backgroundHeight = max(ConstantVars.tabBarTotalHeight, fromAttributes.backgroundHeight + (toAttributes.backgroundHeight - fromAttributes.backgroundHeight) * progress)
        let topPadding = fromAttributes.topPadding + (toAttributes.topPadding - fromAttributes.topPadding) * progress
        let toolbarOffset = fromAttributes.toolbarOffset + (toAttributes.toolbarOffset - fromAttributes.toolbarOffset) * progress
        
        /// move a bit faster for the toolbar
        let fasterProgress = min(1, progress * Constants.tabBarToolbarAlphaMultiplier)
        let toolbarAlpha = fromAttributes.toolbarAlpha + (toAttributes.toolbarAlpha - fromAttributes.toolbarAlpha) * fasterProgress
        
        let topLineAlpha = fromAttributes.topLineAlpha + (toAttributes.topLineAlpha - fromAttributes.topLineAlpha) * progress

        self.backgroundColor = backgroundColor
        self.backgroundHeight = backgroundHeight
        self.topPadding = topPadding
        self.toolbarOffset = toolbarOffset
        self.toolbarAlpha = toolbarAlpha
        self.topLineAlpha = topLineAlpha
    }
}

struct PhotosIconAttributes: AnimatableAttributes {
    
    var foregroundColor: UIColor
    var backgroundHeight: CGFloat
    
    /// when active tab is camera
    static let inactiveDarkBackground: Self = { /// `Self` could also be `PhotosIconAttributes`
        return .init(
            foregroundColor: UIColor.white,
            backgroundHeight: 48
        )
    }()
    
    static let inactiveLightBackground: Self = {
        return .init(
            foregroundColor: UIColor(hex: 0x7e7e7e),
            backgroundHeight: 48
        )
    }()
    
    /// always light background
    static let active: Self = {
        return .init(
            foregroundColor: UIColor(hex: 0x40C74D),
            backgroundHeight: 48
        )
    }()
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
    
    
    static let inactive: Self = {
        return .init(
            foregroundColor: UIColor(hex: 0x7e7e7e).withAlphaComponent(0.5),
            backgroundHeight: 48,
            length: 26,
            rimColor: UIColor(hex: 0x7e7e7e),
            rimWidth: 1
        )
    }()
    
    static let active: Self = {
        return .init(
            foregroundColor: UIColor(hex: 0x00aeef).withAlphaComponent(0.5),
            backgroundHeight: 98,
            length: 64,
            rimColor: .white,
            rimWidth: 3
        )
    }()
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
    
    static let inactiveDarkBackground: ListsIconAttributes = {
        return .init(
            foregroundColor: UIColor.white,
            backgroundHeight: 48
        )
    }()
    
    static let inactiveLightBackground: ListsIconAttributes = {
        return .init(
            foregroundColor: UIColor(hex: 0x7e7e7e),
            backgroundHeight: 48
        )
    }()
    
    static let active: ListsIconAttributes = {
        return .init(
            foregroundColor: UIColor(hex: 0xFFC600),
            backgroundHeight: 48
        )
    }()
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

extension UIColor {
    var color: Color {
        return Color(self)
    }
}




