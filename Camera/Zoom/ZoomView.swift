//
//  ZoomView.swift
//  Camera
//
//  Created by Zheng on 11/19/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

struct DotSpacerView: View {
    var body: some View {
        Color.clear
    }
}


struct ZoomFactorView: View {
    @Binding var zoom: CGFloat
    let value: CGFloat
    let activationProgress: CGFloat
    let isExpanded: Bool
    let isActive: Bool
    let offset: CGFloat
    
    @GestureState private var isTapped = false
    
    var body: some View {
        ZoomFactorContent(text: isActive ? zoom.string : value.string)
            .scaleEffect(isExpanded || isActive ? 1 : 0.8)
            .opacity(!isExpanded || isActive ? 1 : 0)
            .offset(x: offset, y: 0)
            .background(
                Button {
                    print("pressed!")
                    //                zoom = value
                } label: {
                    ZoomFactorContent(text: value.string)
                        .scaleEffect(activationProgress)
                }
                    .opacity(isExpanded ? 1 : 0)
            )
    }
}

struct ZoomFactorContent: View {
    let text: String
    var body: some View {
        ZStack {
            Color(UIColor(hex: 0x002F3B))
                .opacity(0.8)
                .cornerRadius(16)
            
            Text(text)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(C.zoomFactorPadding)
        .frame(width: C.zoomFactorLength, height: C.zoomFactorLength)
    }
}


struct ZoomView: View {
    
    @State var zoom: CGFloat = 1
    @GestureState var draggingAmount = CGFloat(0)
    
    @State var isExpanded = false
    @State var savedExpandedOffset = CGFloat(0)
    
    @State var gestureStarted = false
    @State var keepingExpandedUUID: UUID?
    
    var body: some View {
        Color.green.overlay(
            Color(UIColor(hex: 0x002F3B))
                .opacity(0.25)
                .frame(width: isExpanded ? nil : C.zoomFactorLength * 3 + C.edgePadding * 2, height: C.zoomFactorLength + C.edgePadding * 2)
                .overlay(
                    
                    HStack(spacing: 0) {
                        ForEach(C.zoomFactors, id: \.self) { zoomFactor in
                            let isActive = zoomFactor.zoomRange.contains(zoom)
                            
                            ZoomFactorView(
                                zoom: $zoom,
                                value: zoomFactor.zoomRange.lowerBound,
                                activationProgress: getActivationProgress(for: zoomFactor),
                                isExpanded: isExpanded,
                                isActive: isActive,
                                offset: isExpanded && isActive ? activeZoomFactorOffset(for: zoomFactor) : 0
                            )
                                .zIndex(1)
                            
                            DotSpacerView()
                                .frame(width: isExpanded ? dotViewWidth(for: zoomFactor) : 0, height: 5)
                                .zIndex(0)
                        }
                    }
                        .frame(width: isExpanded ? sliderWidth() : nil, alignment: .leading)
                        .background(
                            Color.clear.overlay(
                                HStack {
                                    ForEach(0..<80) { _ in
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 5, height: 5)
                                    }
                                }
                                    .opacity(0.5)
                                    .drawingGroup()
                                , alignment: .leading
                                
                            )
                                .clipped()
                                .opacity(isExpanded ? 1 : 0)
                        )
                        .offset(x: isExpanded ? (savedExpandedOffset + draggingAmount + sliderLeftPadding()) : 0, y: 0)
                    , alignment: isExpanded ? .leading : .center
                )
                .cornerRadius(50)
        )
        
        
            .onAppear {
                savedExpandedOffset = -C.zoomFactors[1].positionRange.lowerBound * sliderWidth()
                /// This will be from 0 to 1, from slider leftmost to slider rightmost
                let positionInSlider = positionInSlider()
                setZoom(positionInSlider: positionInSlider)
            }
            .highPriorityGesture(
                DragGesture(minimumDistance: 0)
                    .updating($draggingAmount) { value, draggingAmount, transaction in
                        let offset = savedExpandedOffset + value.translation.width
                        
                        if offset >= 0 {
                            draggingAmount = 0
                            DispatchQueue.main.async { savedExpandedOffset = 0 }
                        } else if -offset >= sliderWidth() {
                            draggingAmount = 0
                            DispatchQueue.main.async { savedExpandedOffset = -sliderWidth() }
                        } else {
                            draggingAmount = value.translation.width
                        }
                        
                        
                        if offset < 0 && -offset < sliderWidth() {
                            draggingAmount = value.translation.width
                        }
                        /// This will be from 0 to 1, from slider leftmost to slider rightmost
                        let positionInSlider = positionInSlider()
                        setZoom(positionInSlider: positionInSlider)
                        
                        if !gestureStarted {
                            DispatchQueue.main.async {
                                keepingExpandedUUID = UUID()
                                gestureStarted = true
                            }
                        }
                        
                        if !isExpanded {
                            DispatchQueue.main.async {
                                withAnimation {
                                    isExpanded = true
                                }
                            }
                        }
                    }
                    .onEnded { value in
                        let offset = savedExpandedOffset + value.translation.width
                        if offset >= 0 {
                            savedExpandedOffset = 0
                        } else if -offset >= sliderWidth() {
                            savedExpandedOffset = -sliderWidth()
                        } else {
                            savedExpandedOffset += value.translation.width
                        }
                        /// This will be from 0 to 1, from slider leftmost to slider rightmost
                        let positionInSlider = positionInSlider()
                        setZoom(positionInSlider: positionInSlider)
                        
                        gestureStarted = false
                        let uuidToCheck = keepingExpandedUUID
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            
                            /// make sure another swipe hasn't happened yet
                            if uuidToCheck == keepingExpandedUUID {
                                keepingExpandedUUID = nil
                                withAnimation {
                                    isExpanded = false
                                }
                            }
                        }
                    }
            )
    }
}
extension ZoomView {
    
    /// width of screen, inset from padding
    func availableScreenWidth() -> CGFloat {
        let availableWidth = UIScreen.main.bounds.width - (C.edgePadding * 2)
        return availableWidth
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
        //        let halfSpacing = C.spacing
        let padding = halfAvailableScreenWidth - halfZoomFactorWidth
        return padding
    }
    
    /// from 0 to 1, from slider leftmost to slider rightmost
    func positionInSlider() -> CGFloat {
        /// add current `draggingAmount` to the saved offset
        let draggingProgress = savedExpandedOffset + draggingAmount
        let sliderTotalTrackWidth = sliderWidth()
        
        /// drag finger left = negative `draggingProgress
        /// so, make `draggingProgress` positive
        let positionInSlider = -draggingProgress / sliderTotalTrackWidth
        return positionInSlider
    }
    
    /// offset for the active zoom factor
    func activeZoomFactorOffset(for zoomFactor: ZoomFactor) -> CGFloat {
        let position = zoomFactor.positionRange.lowerBound * sliderWidth()
        let currentOffset = savedExpandedOffset + draggingAmount
        
        /// `currentOffset` is negative, make positive, then subtract `position`
        let offset = -currentOffset - position
        return offset
    }
    
    func getActivationProgress(for zoomFactor: ZoomFactor) -> CGFloat {
        let lower = zoomFactor.positionRange.lowerBound
        let positionInSlider = positionInSlider()
        
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

struct ZoomView_Previews: PreviewProvider {
    static var previews: some View {
        ZoomView()
            .frame(maxWidth: .infinity)
            .padding(50)
            .background(Color.gray)
    }
}

