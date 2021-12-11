//
//  PopoverTemplateViews.swift
//  Popover
//
//  Created by Zheng on 12/10/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

struct VerticalPathShape: Shape {
    
    var start: CGPoint
    var end: CGPoint
    var steepness = CGFloat(0.4)
    
    var animatableData: AnimatablePair<CGPoint.AnimatableData, CGPoint.AnimatableData> {
            get { AnimatablePair(start.animatableData, end.animatableData) }
            set { (start.animatableData, end.animatableData) = (newValue.first, newValue.second) }
        }
//    var progress = CGFloat(1)
//    var animatableData: CGFloat {
//        get { progress }
//        set { self.progress = newValue }
//    }
    
    
    func path(in rect: CGRect) -> Path {
        let height = end.y - start.y
        let topControlPoint = CGPoint(x: start.x, y: start.y + height * steepness)
        let bottomControlPoint = CGPoint(x: end.x, y: end.y - height * steepness)
        
        var path = Path()
        path.move(to: start)
        path.addCurve(to: end, control1: topControlPoint, control2: bottomControlPoint)
        
        return path
    }
}
