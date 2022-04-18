//
//  LaunchConstants.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

enum LaunchConstants {
    static let showUIDelay = CGFloat(5)
    static let showUIDuration = CGFloat(1.2)
    
    static let textDepth = Float(0.008)
    static let textHeight = CGFloat(0.08)
    
    static let tileGap = Float(0.01)
    static let tileLength = Float(0.1)
    static let tileDepth = Float(0.02)
    static let tileCornerRadius = Float(0.05)
    
    static let tileFont = CTFontCreateWithName("SFUI-Semibold" as CFString, LaunchConstants.textHeight, nil)
    
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
    
    /// straight above looks like this:
//    camera.transform.rotation = simd_quatf(
//        angle: 90.asRadians,
//        axis: [-1, 0, 0]
//    )
    
    static let cameraPositionBeforeEnter = SIMD3<Float>(
        x: 0.000001,
        y: 0.8,
        z: 0
    )
    
    static let cameraPositionAfterEnter = SIMD3<Float>(
        x: 0,
        y: 0.03,
        z: 0
    )
    
    static let tileYOffsetLimit = Float(0.1)
    static let tileDiagonalOffsetLimit = Float(0.2)
    
    static let findTileFinalYOffset = Float(0.08)
    
    static let tilesInitialAnimationDuration = CGFloat(9)
    static let tilesFinalAnimationDuration = CGFloat(4)
 
    static let tilesRepeatingAnimationDelay = CGFloat(1.2)
    
    /// time to flip half way.
    /// tiles are flipped 360 degrees, so this is multiplied by 2.
    static let tilesRepeatingAnimationDuration = CGFloat(0.9)
    
    static let findTileAnimationDelay = CGFloat(5.5)
    static let findTileAnimationIndividualDuration = CGFloat(0.5)
    static let findTileAnimationTotalDuration = CGFloat(1) /// time to start all 4 tiles

    static let enterBeforeDuration = CGFloat(1.2)
    static let enterAfterDuration = CGFloat(1.4)
}
