//
//  ZoomModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/7/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct ZoomFactor: Hashable {
    /// range of the zoom label (what the user sees)
    /// example: `0.5...1`
    var zoomLabelRange: ClosedRange<CGFloat>
    
    /// 0 = aspect fit
    /// 1 = aspect fill
    var aspectRatioRange: ClosedRange<CGFloat>
    
    /// range of actual zoom
    /// example: `1...2`
    var zoomRange: ClosedRange<CGFloat>
    
    /// position relative to entire slider
    /// example: `0.0..<0.3`
    var positionRange: ClosedRange<CGFloat>
    
    var activationProgress: CGFloat = 1
}
