//
//  LaunchConstants.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

enum LaunchConstants {
    static var textDepth = Float(0.008)
    static var textHeight = CGFloat(0.08)
    
    static let tileGap = Float(0.01)
    static let tileLength = Float(0.1)
    static let tileDepth = Float(0.02)
    static let tileCornerRadius = Float(0.05)
    
    static let tileGenerationOffsetLimit = Float(0.1)

    static let cameraPositionInitial = SIMD3<Float>(
        x: 0.000001, /// can't be 0
        y: 0.054, /// height of camera
        z: 0.04 /// larger = steeper/more sloped tiles
    )
    
    static let cameraPositionFinal = SIMD3<Float>(
        x: 0.024,
        y: 0.96, /// height of camera
        z: 0.3 /// larger = steeper/more sloped tiles
    )
}

