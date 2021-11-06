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
            photosIconAttributes = tabState.iconAttributes(iconType: .photos)
            listsIconAttributes = tabState.iconAttributes(iconType: .lists)
            
            print("Lists: \(photosIconAttributes)")
        }
    }
    @Published var photosIconAttributes = IconAttributes.Photos.inactiveDarkBackground
    @Published var listsIconAttributes = IconAttributes.Lists.inactiveDarkBackground
}

enum TabState: Equatable {
    case photos
    case camera
    case lists
    case cameraToPhotos(CGFloat) /// associatedValue is the percentage
    case cameraToLists(CGFloat)
    
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
    
    /// `iconType` must either be Photos or Lists
    func iconAttributes(iconType: TabState) -> IconAttributes {
        switch self {
        case .photos:
            switch iconType {
            case .photos:
                return .Photos.active
            case .lists:
                return .Lists.inactiveLightBackground
            default: fatalError("Must pass in Photos or Lists")
            }
        case .camera:
            switch iconType {
            case .photos:
                return .Photos.inactiveDarkBackground
            case .lists:
                return .Lists.inactiveDarkBackground
            default: fatalError("Must pass in Photos or Lists")
            }
        case .lists:
            switch iconType {
            case .photos:
                return .Photos.inactiveLightBackground
            case .lists:
                return .Lists.active
            default: fatalError("Must pass in Photos or Lists")
            }
        case .cameraToPhotos(let transitionProgress):
            switch iconType {
            case .photos:
                return IconAttributes(progress: transitionProgress, from: .Photos.inactiveDarkBackground, to: .Photos.active)
            case .lists:
                return IconAttributes(progress: transitionProgress, from: .Lists.inactiveDarkBackground, to: .Lists.inactiveLightBackground)
            default: fatalError("Must pass in Photos or Lists")
            }
        case .cameraToLists(let transitionProgress):
            switch iconType {
            case .photos:
                return IconAttributes(progress: transitionProgress, from: .Photos.inactiveDarkBackground, to: .Photos.inactiveLightBackground)
            case .lists:
                return IconAttributes(progress: transitionProgress, from: .Lists.inactiveDarkBackground, to: .Lists.active)
            default: fatalError("Must pass in Photos or Lists")
            }
        }
    }
}

/// grouping of all visual properties, for setting active/inactive
/// also for animations
struct IconAttributes {
    /// transition + animation
    
    var foregroundColor: UIColor
    var backgroundHeight: CGFloat
    
    struct Photos {
        
        /// when active tab is camera
        static let inactiveDarkBackground: IconAttributes = {
            return IconAttributes(
                foregroundColor: UIColor.white,
                backgroundHeight: 48
            )
        }()
        
        static let inactiveLightBackground: IconAttributes = {
            return IconAttributes(
                foregroundColor: UIColor(hex: 0x7e7e7e),
                backgroundHeight: 48
            )
        }()
        
        /// always light background
        static let active: IconAttributes = {
            return IconAttributes(
                foregroundColor: UIColor(hex: 0x40C74D),
                backgroundHeight: 48
            )
        }()
    }
    
    struct Lists {
        static let inactiveDarkBackground: IconAttributes = {
            return IconAttributes(
                foregroundColor: UIColor.white,
                backgroundHeight: 48
            )
        }()
        
        static let inactiveLightBackground: IconAttributes = {
            return IconAttributes(
                foregroundColor: UIColor(hex: 0x7e7e7e),
                backgroundHeight: 48
            )
        }()
        
        static let active: IconAttributes = {
            return IconAttributes(
                foregroundColor: UIColor(hex: 0xFFC600),
                backgroundHeight: 48
            )
        }()
    }
    
    static func mixAttributes(progress: CGFloat, from: IconAttributes, to: IconAttributes) -> IconAttributes {
        let foregroundColor = from.foregroundColor.toColor(to.foregroundColor, percentage: progress)
        let backgroundHeight = from.backgroundHeight + (to.backgroundHeight - from.backgroundHeight) * progress
        return IconAttributes(foregroundColor: foregroundColor, backgroundHeight: backgroundHeight)
    }
}

extension IconAttributes {
    init(progress: CGFloat, from fromAttributes: IconAttributes, to toAttributes: IconAttributes) {
        self = IconAttributes.mixAttributes(progress: progress, from: fromAttributes, to: toAttributes)
    }
}

struct CameraAttributes {
    var backgroundHeight: CGFloat
    
    /// length of circle
    var length: CGFloat
    var fillColor: UIColor
    var rimColor: UIColor
    var rimWidth: CGFloat
    
    
    static let inactive: CameraAttributes = {
        return CameraAttributes(
            backgroundHeight: 48,
            length: CGFloat(26),
            fillColor: UIColor(hex: 0x7e7e7e).withAlphaComponent(0.5),
            rimColor: UIColor(hex: 0x7e7e7e),
            rimWidth: 1
        )
    }()
    
    static let active: CameraAttributes = {
        return CameraAttributes(
            backgroundHeight: 98,
            length: CGFloat(64),
            fillColor: UIColor(hex: 0x00aeef).withAlphaComponent(0.5),
            rimColor: UIColor.white,
            rimWidth: 3
        )
    }()
}

extension UIColor {
    var color: Color {
        return Color(self)
    }
}







//enum TabTransitionState {
//    case cameraToPhotos(CGFloat) /// associatedValue is the percentage
//    case cameraToLists(CGFloat)
//}

//protocol Attributes {
//    var foregroundColor: UIColor { get set }
//    var backgroundHeight: CGFloat { get set }
//
//    var secondaryForegroundColor: UIColor { get set }
//    var circleLength: CGFloat { get set }
//
////    var backgroundHeight: CGFloat
//
//    /// length of circle
////    var length: CGFloat
////    var fillColor: Color
////    var rimColor: Color
////    var rimWidth: CGFloat
//
//}



/// switch over the current, actual tab state FOR each individual tab
//    func attributes(for staticTabState: TabState) -> TransitionAttributes {
//        switch self {
//        case .photos:
//            switch staticTabState {
//            case .photos:
//                return TransitionAttributes(progress: 1, targetAttributes: .icon(.Photos.active))
//            case .camera:
//                return TransitionAttributes(progress: 1, targetAttributes: .camera(.inactive))
//            case .lists:
//                return TransitionAttributes(progress: 1, targetAttributes: .icon(.Lists.inactiveLightBackground))
//            default: break
//            }
//        case .camera:
//            switch staticTabState {
//            case .photos:
//                return TransitionAttributes(progress: 1, targetAttributes: .icon(.Photos.inactiveLightBackground))
//            case .camera:
//                return TransitionAttributes(progress: 1, targetAttributes: .camera(.active))
//            case .lists:
//                return TransitionAttributes(progress: 1, targetAttributes: .icon(.Lists.inactiveLightBackground))
//            default: break
//            }
//        case .lists:
//            switch staticTabState {
//            case .photos:
//                return TransitionAttributes(progress: 1, targetAttributes: .icon(.Photos.inactiveLightBackground))
//            case .camera:
//                return TransitionAttributes(progress: 1, targetAttributes: .camera(.inactive))
//            case .lists:
//                return TransitionAttributes(progress: 1, targetAttributes: .icon(.Lists.active))
//            default: break
//            }
//        case .cameraToPhotos(let transitionProgress):
//            switch staticTabState {
//            case .photos:
//                return TransitionAttributes(progress: transitionProgress, targetAttributes: .icon(.Photos.active))
//            case .camera:
//                return TransitionAttributes(progress: transitionProgress, targetAttributes: .camera(.inactive))
//            case .lists:
//                return TransitionAttributes(progress: transitionProgress, targetAttributes: .icon(.Lists.inactiveLightBackground))
//            default: break
//            }
//        case .cameraToLists(let transitionProgress):
//            switch staticTabState {
//            case .photos:
//                return TransitionAttributes(progress: transitionProgress, targetAttributes: .icon(.Photos.inactiveLightBackground))
//            case .camera:
//                return TransitionAttributes(progress: transitionProgress, targetAttributes: .camera(.inactive))
//            case .lists:
//                return TransitionAttributes(progress: transitionProgress, targetAttributes: .icon(.Lists.active))
//            default: break
//            }
//        }
//
//        fatalError("Fell through, shouldn't have.")
//    }
