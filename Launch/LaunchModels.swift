//
//  LaunchModels.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
 import UIKit

/// Row of launch text
/// X X X X X X
struct LaunchTextRow {
    var text = [LaunchText]()
}

struct LaunchText {
    var character: String
    var color: UIColor
    var position: Position?
    
    enum Position {
        case ranged(startingOffset: Float, range: Float)
        case callout(startingOffset: Float, finalOffset: Float) /// for find
    }
}
 
