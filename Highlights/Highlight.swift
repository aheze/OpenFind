//
//  Highlight.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/31/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//
    
import UIKit


struct Highlight: Identifiable, Hashable {
    let id = UUID()
    var string = ""
    var colors = [UIColor]()
    var alpha = CGFloat(1)
    var position = Position()
    
    /// State
    var state = State.added
    
    struct Position: Equatable {
        /// frame of the container sentence
        var sentenceFrame = CGRect.zero
        
        /// midpoint of the highlight, to the screen
        var globalCenter = CGPoint.zero
        var horizontalOffset = CGFloat(0)
        var length = CGFloat(0)
        var angle = CGFloat(0)
    }
    
    enum State: Equatable {
        case reused
        case added
        case lingering(cyclesWithoutNeighbor: Int) /// `cyclesWithoutNeighbor` how many frames the highlight wasn't near any other new highlights
        
        static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.reused, .reused):
                return true
            case (.added, .added):
                return true
            case (.lingering(let lhsCycles), .lingering(let rhsCycles)):
                return lhsCycles == rhsCycles
            default:
                return false
            }
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
