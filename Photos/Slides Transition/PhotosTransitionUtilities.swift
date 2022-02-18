//
//  PhotosTransitionUtilities.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/17/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

public extension CGRect {
    /// Kinda like AVFoundation.AVMakeRect, but handles tall-skinny aspect ratios differently.
    /// Returns a rectangle of the same aspect ratio, but scaleAspectFit inside the other rectangle.
    static func makeRect(aspectRatio: CGSize, insideRect rect: CGRect) -> CGRect {
        let viewRatio = rect.width / rect.height
        let imageRatio = aspectRatio.width / aspectRatio.height
        let touchesHorizontalSides = (imageRatio > viewRatio)

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
