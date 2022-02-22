//
//  ExtendedCurveConnector.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Popovers
import SwiftUI

struct ExtendedCurveConnector: Shape {
    /// The start point.
    public var start: CGPoint

    public var middle: CGPoint

    /// The end point.
    public var end: CGPoint

    /// The curve's steepness.
    public var steepness = CGFloat(0.3)

    /// The curve's direction.
    public var direction = Templates.CurveConnector.Direction.vertical

    /**
     A curved line between 2 points.
     - parameter start: The start point.
     - parameter end: The end point.
     - parameter steepness: The curve's steepness.
     - parameter direction: The curve's direction.
     */
    public init(
        start: CGPoint,
        middle: CGPoint,
        end: CGPoint,
        steepness: CGFloat = CGFloat(0.3),
        direction: Templates.CurveConnector.Direction = .vertical
    ) {
        self.start = start
        self.middle = middle
        self.end = end
        self.steepness = steepness
        self.direction = direction
    }

    /**
     Horizontal or Vertical line.
     */
    public enum Direction {
        case horizontal
        case vertical
    }

    /// Allow animations. From https://www.objc.io/blog/2020/03/10/swiftui-path-animations/
    public var animatableData: AnimatablePair<CGPoint.AnimatableData, AnimatablePair<CGPoint.AnimatableData, CGPoint.AnimatableData>> {
        get { AnimatablePair(start.animatableData, AnimatablePair(middle.animatableData, end.animatableData)) }
        set {
            start.animatableData = newValue.first
            middle.animatableData = newValue.second.first
            end.animatableData = newValue.second.second
        }
    }
    

    /// Draw the curve.
    public func path(in _: CGRect) -> Path {
        let middleControlPoint: CGPoint
        let endControlPoint: CGPoint

        switch direction {
        case .horizontal:
            let curveWidth = end.x - middle.x
            let curveSteepness = curveWidth * steepness
            middleControlPoint = CGPoint(x: middle.x + curveSteepness, y: middle.y)
            endControlPoint = CGPoint(x: end.x - curveSteepness, y: end.y)
        case .vertical:
            let curveHeight = end.y - middle.y
            let curveSteepness = curveHeight * steepness
            middleControlPoint = CGPoint(x: middle.x, y: middle.y + curveSteepness)
            endControlPoint = CGPoint(x: end.x, y: end.y - curveSteepness)
        }

        var path = Path()
        path.move(to: start)
        path.addLine(to: middle)
        path.addCurve(to: end, control1: middleControlPoint, control2: endControlPoint)
        return path
    }
}
