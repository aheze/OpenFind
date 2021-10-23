//
//  ScrollTimer.swift
//  SearchBar
//
//  Created by Zheng on 10/22/21.
//

import UIKit

struct ScrollTimer {
    
    var displayLink: CADisplayLink
    var startTime = CGFloat(0)
    var animationLength = CGFloat(1)
    var beginningOffset = CGFloat(0)
    var targetOffsetDelta = CGFloat(0)
}
