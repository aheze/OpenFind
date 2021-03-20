//
//  Positions.swift
//  FindAppClip1
//
//  Created by Zheng on 3/12/21.
//

import UIKit

struct Positions {
    static var deviceHasNotch = false
    
    /// top height of camera down to the shadow, doesn't include bottom less-alpha view
    static var adjustedTopStop = CGFloat(0)
    
    /// top height including bottom
    static var topStop = CGFloat(0)
    static var bottomStop = CGFloat(0)
}
