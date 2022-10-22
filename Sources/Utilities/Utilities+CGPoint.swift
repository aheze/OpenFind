//
//  Utilities+CGPoint.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/26/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension CGPoint {
    /// from https://stackoverflow.com/a/33158630/14351818
    func angle(to comparisonPoint: CGPoint) -> CGFloat {
        let originX = comparisonPoint.x - x
        let originY = comparisonPoint.y - y
        let bearingRadians = atan2f(Float(originY), Float(originX))
        var bearingDegrees = CGFloat(bearingRadians).radiansToDegrees

        while bearingDegrees < 0 {
            bearingDegrees += 360
        }

        return bearingDegrees
    }
}

func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
    return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
}

func CGPointDistance(from: CGPoint, to: CGPoint) -> CGFloat {
    return sqrt(CGPointDistanceSquared(from: from, to: to))
}
