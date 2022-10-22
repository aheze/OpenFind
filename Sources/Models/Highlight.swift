//
//  Highlight.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/31/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//
    
import UIKit

struct Highlight: Identifiable, Hashable {
    var id: UUID
    var string = ""
    var colors = [UIColor]()
    var alpha = CGFloat(1)
    var position = ScannedPosition()
    
    /// State
    var state = State.added

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

struct ScannedPosition: Equatable {
    /// midpoint of the highlight, to the screen. Use this in SwiftUI
    var center = CGPoint.zero
    
    /// dimensions
    var size = CGSize.zero
        
    /// how much to rotate by
    var angle = CGFloat(0)
}

struct Overlay: Identifiable, Hashable {
    let id = UUID()
    var string = ""
    var position = ScannedPosition()

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
