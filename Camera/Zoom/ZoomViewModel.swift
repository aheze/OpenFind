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
}


class ZoomViewModel: ObservableObject {
    @Published var zoom: CGFloat = 1
    
    @Published var isExpanded = false
    @Published var savedExpandedOffset = CGFloat(0)
    
    @Published var gestureStarted = false
    @Published var keepingExpandedUUID: UUID?
    
    var allowingButtonPresses = true
    var sliderWidth = CGFloat(0)
    var sliderLeftPadding = CGFloat(0)
    
    var containerView: UIView
    init(containerView: UIView) {
        self.containerView = containerView
        self.updateSliderWidth()
        self.updateSliderLeftPadding()
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            let previousSliderWidth = self.sliderWidth
            let previousProgress = -self.savedExpandedOffset / previousSliderWidth

            self.updateSliderWidth()
            self.updateSliderLeftPadding()
            
            /// recalculate percent offset based on new screen width
            let savedExpandedOffset = -previousProgress * self.sliderWidth
            self.savedExpandedOffset = savedExpandedOffset
        }
    }
    
    func update(translation: CGFloat, draggingAmount: inout CGFloat) {
        let offset = savedExpandedOffset + translation
        
        if offset >= 0 {
            draggingAmount = 0
            DispatchQueue.main.async { self.savedExpandedOffset = 0 }
        } else if -offset >= sliderWidth {
            draggingAmount = 0
            DispatchQueue.main.async { self.savedExpandedOffset = -self.sliderWidth }
        } else {
            draggingAmount = translation
        }
        
        
        if offset < 0 && -offset < sliderWidth {
            draggingAmount = translation
        }
        
        /// This will be from 0 to 1, from slider leftmost to slider rightmost
        let positionInSlider = positionInSlider(draggingAmount: draggingAmount)
        setZoom(positionInSlider: positionInSlider)
        
        if !gestureStarted {
            DispatchQueue.main.async {
                self.keepingExpandedUUID = UUID()
                self.gestureStarted = true
            }
        }
        
        if !isExpanded {
            DispatchQueue.main.async {
                withAnimation {
                    self.isExpanded = true
                }
            }
        }
    }
    
    
    /// width of the entire slider
    func updateSliderWidth() {
        var width = CGFloat(0)
        
        for index in C.zoomFactors.indices {
            let zoomFactor = C.zoomFactors[index]
            
            var addedWidth = CGFloat(0)
            addedWidth += C.zoomFactorLength
            addedWidth += dotViewWidth(for: zoomFactor)
            width += addedWidth
        }
        
        self.sliderWidth = width
    }
    
    /// have half-screen gap on left side of slider
    func updateSliderLeftPadding() {
        let halfAvailableScreenWidth = availableScreenWidth() / 2
        let halfZoomFactorWidth = C.zoomFactorLength / 2
        let leftPadding = C.edgePadding
        let padding = halfAvailableScreenWidth - halfZoomFactorWidth + leftPadding
        
        self.sliderLeftPadding = padding
    }
    
    /// width of screen, inset from padding
    func availableScreenWidth() -> CGFloat {
        let availableWidth = UIScreen.main.bounds.width - (C.edgePadding * 2)
        let safeArea = containerView.safeAreaInsets
        let safeAreaHorizontalInset = safeArea.left + safeArea.right
        let containerEdgePadding = C.containerEdgePadding * 2
        return availableWidth - containerEdgePadding - safeAreaHorizontalInset
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
        let widthMultiplier = (zoomFactor.positionRange.upperBound - zoomFactor.positionRange.lowerBound) / C.normalPositionRange
        
        /// minus `zoomFactorLength` from the content, so it's only the dot view now
        let finalWidth = (singleContentWidth * widthMultiplier) - C.zoomFactorLength
        return finalWidth
    }
    
    /// offset for the active zoom factor
    func activeZoomFactorOffset(for zoomFactor: ZoomFactor, draggingAmount: CGFloat) -> CGFloat {
        let position = zoomFactor.positionRange.lowerBound * sliderWidth
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
    
    /// from 0 to 1, from slider leftmost to slider rightmost
    func positionInSlider(draggingAmount: CGFloat) -> CGFloat {
        /// add current `draggingAmount` to the saved offset
        let draggingProgress = savedExpandedOffset + draggingAmount
        let sliderTotalTrackWidth = sliderWidth
        
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
    
    func startTimeout() {
        gestureStarted = false
        let uuidToCheck = keepingExpandedUUID
        DispatchQueue.main.asyncAfter(deadline: .now() + C.timeoutTime) {
            
            /// make sure another swipe hasn't happened yet
            if uuidToCheck == self.keepingExpandedUUID {
                self.keepingExpandedUUID = nil
                withAnimation {
                    self.isExpanded = false
                }
            }
        }
    }
    
}
