//
//  Gestures.swift
//  FindAppClip1
//
//  Created by Zheng on 3/12/21.
//

import UIKit

struct GestureState {
    /// Began a gesture, starting from inactive state
    static var began = false
    
    /// If the pan gesture started. If not and long press lifted, then call release pan in the long press.
    static var startedPan = false
    
    /// if true, read value of translation inside .changed
    static var needToDetermineDirection = false
    
    static var savedOffset = CGFloat(0)
}
