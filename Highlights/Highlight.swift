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
    var frame = CGRect.zero
    var colors = [UIColor]()
    
    /// how many frames the highlight wasn't near any other new highlights
    var cyclesWithoutNeighbor = 0
    
    var state = State.added
    
    var alpha = CGFloat(1)
    
    enum State {
        case reused
        case added
        case lingering
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
