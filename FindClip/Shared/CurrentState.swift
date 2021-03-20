//
//  State.swift
//  FindAppClip1
//
//  Created by Zheng on 3/12/21.
//

import UIKit

struct CurrentState {
    
    /// true = presenting bottom layer
    static var currentlyPresenting = false
    
    static var currentlyPaused = false
    
    static var currentlyFullScreen = false
    
    static var flashlightOn = false
    
    static var presentingOverlay = false
}
