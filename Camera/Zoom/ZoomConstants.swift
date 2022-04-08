//
//  ZoomView+Constants.swift
//  Camera
//
//  Created by Zheng on 11/20/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

struct ZoomConstants {
    /// padding underneath blue capsule
    static let bottomPadding = CGFloat(16)
    
    static let maxWidth = CGFloat(300)
    static let containerEdgePadding = CGFloat(16) /// horizontal padding
    
    static var edgePadding = CGFloat(4)
    static var zoomFactorPadding = CGFloat(4)
    static var zoomFactorLength = CGFloat(44)
    
    static let activationStartDistance = CGFloat(0.09)
    static let activationRange = CGFloat(0.06)
    
    /// how wide `positionRange` normally is
    static let normalPositionRange = 0.3
    
    static let timeoutTime = CGFloat(1.5)
    
    static var zoomFactors = [ZoomFactor]()
    
    
    static let scrollViewMinZoom = CGFloat(1)
    static let scrollViewMaxZoom = CGFloat(4)
    
    /// height of the container
    static let containerHeight = (ZoomConstants.zoomFactorLength + ZoomConstants.edgePadding * 2) + ZoomConstants.bottomPadding
}
