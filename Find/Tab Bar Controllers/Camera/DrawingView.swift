//
//  DrawingView.swift
//  Find
//
//  Created by Zheng on 3/29/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

class CustomActionsView: UIView {
    var actions = [UIAccessibilityCustomAction]()
    
    override var accessibilityCustomActions: [UIAccessibilityCustomAction]? {
        get {
            return actions
        }
        set {
            super.accessibilityCustomActions = newValue
        }
    }
}
class DrawingView: UIView {
    var actions = [UIAccessibilityCustomAction]()
    
    override var accessibilityCustomActions: [UIAccessibilityCustomAction]? {
        get {
            return actions
        }
        set {
            super.accessibilityCustomActions = newValue
        }
    }
}
