//
//  CameraConstants.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

enum CameraConstants {
    /// shut off the camera after 6 seconds, after going to another tab
    static var cameraCoolDownDuration = CGFloat(4)
    
    /// once the history reaches this, remove the first history, and append the new history to the end.
    static var maximumHistoryCount = 20
    
    static var resultsCountUpdateDuration = CGFloat(0.8)
    
    static var focusIndicatorLength = CGFloat(80)
}
