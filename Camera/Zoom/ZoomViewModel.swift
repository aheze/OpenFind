//
//  ZoomViewModel.swift
//  Camera
//
//  Created by Zheng on 11/20/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI


struct ZoomFactor: Hashable {
    
    /// range of zoom
    /// example: `0.5..<1`
    var zoomRange: ClosedRange<CGFloat>
    
    /// position relative to entire slider
    /// example: `0.0..<0.25`
    var positionRange: ClosedRange<CGFloat>
    
    /// how wide `positionRange` normally is
    static let normalPositionRange = 0.25
}


class ZoomViewModel: ObservableObject {
    @Published var zoom: CGFloat = 1
    
    @Published var isExpanded = false
    @Published var savedExpandedOffset = CGFloat(0)
    
    @Published var gestureStarted = false
    @Published var keepingExpandedUUID: UUID?
    
    var allowingButtonPresses = true
    
    /// width of screen, inset from padding
    func availableScreenWidth() -> CGFloat {
        let availableWidth = UIScreen.main.bounds.width - (C.edgePadding * 2)
        let containerEdgePadding = C.containerEdgePadding * 2
        return availableWidth - containerEdgePadding
    }
    
    /// width of a dot view
    func dotViewWidth(for zoomFactor: ZoomFactor) -> CGFloat {
        let availableScreenWidth = availableScreenWidth()
        
        /// remove the width of the rightmost zoom factor
        let rightmostZoomFactorWidth = C.zoomFactorLength
        
        /// **(FACTOR)** OOOOOOOOOO **(FACTOR)** OOOOOOOOOO ~~(removed factor)~~
        /// width for 2 zoom factors and 2 dot views, combined
        /// 2x **(FACTOR)** + 2x OOOOOOOOOO
        let totalContentWidth = availableScreenWidth - rightmostZoomFactorWidth
        
        /// divide by 2, since there are 2 dot views total
        let singleContentWidth = totalContentWidth / 2
        
        /// how much to multiply the width by
        /// `upperBound` - `lowerBound` should either be 0.25 or 0.50.
        let widthMultiplier = (zoomFactor.positionRange.upperBound - zoomFactor.positionRange.lowerBound) / ZoomFactor.normalPositionRange
        
        /// minus `zoomFactorLength` from the content, so it's only the dot view now
        let finalWidth = (singleContentWidth * widthMultiplier) - C.zoomFactorLength
        return finalWidth
    }
    
    /// offset for the active zoom factor
    func activeZoomFactorOffset(for zoomFactor: ZoomFactor, draggingAmount: CGFloat) -> CGFloat {
        let position = zoomFactor.positionRange.lowerBound * sliderWidth()
        let currentOffset = savedExpandedOffset + draggingAmount
        
        /// `currentOffset` is negative, make positive, then subtract `position`
        let offset = -currentOffset - position
        return offset
    }
    
    func getActivationProgress(for zoomFactor: ZoomFactor, draggingAmount: CGFloat) -> CGFloat {
        let lower = zoomFactor.positionRange.lowerBound
        let positionInSlider = positionInSlider(draggingAmount: draggingAmount)
        
        var percentActivated = CGFloat(1)
        if positionInSlider < lower {
            let distanceToActivation = min(C.activationStartDistance, lower - positionInSlider)
            percentActivated = 1 - (C.activationStartDistance - distanceToActivation) / C.activationRange
        } else if zoomFactor.positionRange.contains(positionInSlider) {
            let distanceToActivation = min(C.activationStartDistance, positionInSlider - lower)
            percentActivated = 1 - (C.activationStartDistance - distanceToActivation) / C.activationRange
        }
        
        return max(0.001, percentActivated)
    }
    
    
    /// width of the entire slider
    func sliderWidth() -> CGFloat {
        var width = CGFloat(0)
        
        for index in C.zoomFactors.indices {
            let zoomFactor = C.zoomFactors[index]
            
            var addedWidth = CGFloat(0)
            addedWidth += C.zoomFactorLength
            addedWidth += dotViewWidth(for: zoomFactor)
            width += addedWidth
        }
        return width
    }
    
    /// have half-screen gap on left side of slider
    func sliderLeftPadding() -> CGFloat {
        let halfAvailableScreenWidth = availableScreenWidth() / 2
        let halfZoomFactorWidth = C.zoomFactorLength / 2
        let leftPadding = C.edgePadding
        let padding = halfAvailableScreenWidth - halfZoomFactorWidth + leftPadding
        return padding
    }
    
    /// from 0 to 1, from slider leftmost to slider rightmost
    func positionInSlider(draggingAmount: CGFloat) -> CGFloat {
        /// add current `draggingAmount` to the saved offset
        let draggingProgress = savedExpandedOffset + draggingAmount
        let sliderTotalTrackWidth = sliderWidth()
        
        /// drag finger left = negative `draggingProgress
        /// so, make `draggingProgress` positive
        let positionInSlider = -draggingProgress / sliderTotalTrackWidth
        return positionInSlider
    }
    
    
    func setZoom(positionInSlider: CGFloat) {
        /// get the zoom factor whose position contains the fraction
        if let zoomFactor = C.zoomFactors.first(where: { $0.positionRange.contains(positionInSlider) }) {
            let positionRangeLower = zoomFactor.positionRange.lowerBound
            let positionRangeUpper = zoomFactor.positionRange.upperBound
            
            /// `positionInSlider` is starts all the way from the left of the entire slider, need to start it from the position range
            let positionInRange = positionInSlider - positionRangeLower
            let fractionOfPositionRange = positionInRange / (positionRangeUpper - positionRangeLower)
            
            /// example: `0.5..<1.0` becomes `0.5`
            let zoomRangeWidth = zoomFactor.zoomRange.upperBound - zoomFactor.zoomRange.lowerBound
            let zoom = zoomFactor.zoomRange.lowerBound + fractionOfPositionRange * zoomRangeWidth
            
            DispatchQueue.main.async { self.zoom = zoom }
        }
    }
    
}
