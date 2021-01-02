//
//  State.swift
//  FindTabBar
//
//  Created by Zheng on 12/18/20.
//

import UIKit

enum Direction {
    case up
    case down
    case left
    case right
}
class Gestures {
    var isAnimating = false
    var completedMove = false
    var direction: Direction?
    var toOverlay: Bool = true
    var totalTranslation: CGFloat = 0
    
    var framePositionWhenLifted: CGFloat = 0
    var viewToTrackChanges: UIView?
    var gestureSavedOffset: CGFloat = 0
    
    var hasMovedFromPress = false /// if finger has moved after catching with long press
    
    var isRubberBanding = false
    
    var transitionAnimatorBlock: (() -> Void)?
    var transitionAnimatorCompletion: (() -> Void)?
    
}

class ViewControllerState {
    static var currentVC: UIViewController?
    static var newVC: UIViewController? /// only set when swiping via gesture
}

class CameraState {
    static var isOn = false
}

enum ViewControllerType {
    case photos
    case camera
    case lists
}

struct Constants {
    static var rubberBandingPower = CGFloat(0.7)
    static var shutterBoundsLength = CGFloat(92) /// length of the 40x40 containers
    static var framelessShutterBottomDistance = CGFloat(48 - 10) /// iPhone X
    static var framedShutterBottomDistance = CGFloat(30 - 10)
    static var designedWidth = CGFloat(375) /// width of device as designed in sketch
    static var transitionDuration = CGFloat(0.4)
    static var gesturePadding = CGFloat(5) /// extra padding added to max translation
    
    static var detailIconColorDark = UIColor(named: "TabIconDetails-Dark")!
    static var foregroundIconColorDark = UIColor(named: "TabIconForeground-Dark")!
    static var backgroundIconColorDark = UIColor(named: "TabIconBackground-Dark")!
    static var detailIconColorLight = UIColor(named: "TabIconDetails-Light")!
    static var foregroundIconColorLight = UIColor(named: "TabIconForeground-Light")!
    static var backgroundIconColorLight = UIColor(named: "TabIconBackground-Light")!
}

struct ConstantVars { /// calculated based on device size
    static var shutterBottomDistance = CGFloat(0)
    static var cameraShutterAvoidFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
    static var photoFilterAvoidFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
}
