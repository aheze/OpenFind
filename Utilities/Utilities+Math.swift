//
//  Utilities+Math.swift
//  Find
//
//  Created by Zheng on 12/3/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

/// for easier multiplying in `ShutterShapeAttributes`
extension CGPoint {
    static func * (left: CGPoint, scalar: CGFloat) -> CGPoint {
        return CGPoint(x: left.x * scalar, y: left.y * scalar)
    }

    static func * (scalar: CGFloat, right: CGPoint) -> CGPoint {
        return CGPoint(x: right.x * scalar, y: right.y * scalar)
    }

    static func + (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }

    static func - (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }

    func distance(from p: CGPoint) -> CGFloat {
        return sqrt(((x - p.x) * (x - p.x)) + ((y - p.y) * (y - p.y)))
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places: Int) -> Double {
        let multiplier = pow(10, Double(places))
        return (self * multiplier).rounded() / multiplier
    }
}

extension CGFloat {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places: Int) -> Double {
        let multiplier = pow(10, Double(places))
        return (Double(self) * multiplier).rounded() / multiplier
    }
}

extension BinaryInteger {
    var degreesToRadians: CGFloat { CGFloat(self) * .pi / 180 }
}

extension FloatingPoint {
    var degreesToRadians: Self { self * .pi / 180 }
    var radiansToDegrees: Self { self * 180 / .pi }
}
