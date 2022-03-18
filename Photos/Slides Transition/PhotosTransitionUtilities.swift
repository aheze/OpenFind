//
//  PhotosTransitionUtilities.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/17/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

public extension CGFloat {
    /// Returns the value, scaled-and-shifted to the targetRange.
    /// If no target range is provided, we assume the unit range (0, 1)
    static func scaleAndShift(
        value: CGFloat,
        inRange: (min: CGFloat, max: CGFloat),
        toRange: (min: CGFloat, max: CGFloat) = (min: 0.0, max: 1.0)
    ) -> CGFloat {
        assert(inRange.max > inRange.min)
        assert(toRange.max > toRange.min)

        if value < inRange.min {
            return toRange.min
        } else if value > inRange.max {
            return toRange.max
        } else {
            let ratio = (value - inRange.min) / (inRange.max - inRange.min)
            return toRange.min + ratio * (toRange.max - toRange.min)
        }
    }
}

public extension CGRect {
    /// Kinda like AVFoundation.AVMakeRect, but handles tall-skinny aspect ratios differently.
    /// Returns a rectangle of the same aspect ratio, but scaleAspectFit inside the other rectangle.
    static func makeRect(aspectRatio: CGSize, insideRect rect: CGRect) -> CGRect {
        let viewRatio = rect.width / rect.height
        var imageRatio = aspectRatio.width / aspectRatio.height
        let touchesHorizontalSides = (imageRatio > viewRatio)
        
        if imageRatio.isNaN {
            
            print("     NAN inside `makeRect`! aspectRatio: \(aspectRatio) insideRect rect: \(rect). viewRatio: \(viewRatio), imageRatio: \(imageRatio), touchesHorizontalSides: \(touchesHorizontalSides)")
            imageRatio = 0
        }

        let result: CGRect
        if touchesHorizontalSides {
            let height = rect.width / imageRatio
            let yPoint = rect.minY + (rect.height - height) / 2
            result = CGRect(x: rect.origin.x, y: yPoint, width: rect.width, height: height)
        } else {
            let width = rect.height * imageRatio
            let xPoint = rect.minX + (rect.width - width) / 2
            result = CGRect(x: xPoint, y: rect.origin.y, width: width, height: rect.height)
        }
        return result
    }
}
