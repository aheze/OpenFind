//
//  ZoomView.swift
//  Camera
//
//  Created by Zheng on 11/19/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

//struct DotView: View {
//    var body: some View {
//        Color.blue.opacity(0.8).background(
//            HStack {
//                ForEach(0..<25) { _ in
//                    Circle()
//                        .fill(Color.white)
//                        .frame(width: 5, height: 5)
//                }
//            }
//        )
//            .drawingGroup() /// make sure circles don't disappear
//            .clipped()
//            .border(Color.red, width: 5)
//    }
//}

struct DotSpacerView: View {
    var body: some View {
        Color.blue
            .opacity(0.8)
            .border(Color.red, width: 5)
    }
}
struct ZoomView: View {
    
    @State var zoom: CGFloat = 1
    @GestureState var draggingAmount = CGFloat(0)
    
    @State var isExpanded = true
    @State var savedExpandedOffset = CGFloat(0)
    
    @State var gestureStarted = false
    @State var keepingExpandedUUID: UUID?
    
    var body: some View {
        Color.clear.overlay(
            HStack(spacing: C.spacing) {
                ForEach(C.zoomFactors, id: \.self) { zoomFactor in
                    let isActive = zoomFactor.zoomRange.contains(zoom)
                    
                    ZoomPresetView(
                        zoom: $zoom,
                        value: zoomFactor.zoomRange.lowerBound,
                        isActive: isActive
                    )
                        .offset(x: isActive ? activeZoomFactorOffset(for: zoomFactor) : 0, y: 0)
                        .zIndex(1)
                    
                    DotSpacerView()
                        .frame(width: isExpanded ? dotViewWidth(for: zoomFactor) : 0)
                        .zIndex(0)
                }
            }
                .padding(.vertical, 10)
                .background(
                    HStack {
                        ForEach(0..<80) { _ in
                            Circle()
                                .fill(Color.white)
                                .frame(width: 5, height: 5)
                        }
                    }
                        .drawingGroup()
                        .clipped()
                )
            
                .frame(width: isExpanded ? sliderWidth() : nil, alignment: .leading)
                .border(Color.cyan, width: 3)
                .clipped()
                .offset(x: isExpanded ? (savedExpandedOffset + draggingAmount + sliderLeftPadding()) : 0, y: 0)
            , alignment: .leading)
            .padding(C.edgePadding)
            .background(
                Color(UIColor(hex: 0x002F3B))
                //                    .opacity(0.25)
            )
            .cornerRadius(50)
            .highPriorityGesture(
                DragGesture(minimumDistance: 0)
                    .updating($draggingAmount) { value, draggingAmount, transaction in
                        draggingAmount = value.translation.width
                        
                        /// add current `draggingAmount` to the saved offset
                        let draggingProgress = savedExpandedOffset + draggingAmount
                        let sliderTotalTrackWidth = sliderWidth()
                        
                        /// drag finger left = negative `draggingProgress
                        /// so, make `draggingProgress` positive
                        /// This will be from 0 to 1, from slider leftmost to slider rightmost
                        let positionInSlider = -draggingProgress / sliderTotalTrackWidth
                        
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
                        } else {
                            DispatchQueue.main.async { self.zoom = 0 } /// TODO, remove
                        }
                        
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
                        savedExpandedOffset += value.translation.width
                        gestureStarted = false
                        //                        let uuidToCheck = keepingExpandedUUID
                        //                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        //
                        //                            /// make sure another swipe hasn't happened yet
                        //                            if uuidToCheck == keepingExpandedUUID {
                        //                                keepingExpandedUUID = nil
                        //                                withAnimation {
                        //                                    isExpanded = false
                        //                                }
                        //                            }
                        //                        }
                    }
            )
    }
}

struct ZoomPresetView: View {
    @Binding var zoom: CGFloat
    let value: CGFloat
    let isActive: Bool
    
    @GestureState private var isTapped = false
    
    var body: some View {
        Button {
            zoom = value
        } label: {
            Text(String(value.string))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: C.zoomFactorLength, height: C.zoomFactorLength)
            //                .scaleEffect(isActive ? 1 : 0.7)
                .background(
                    Color(isActive ? UIColor.orange : UIColor(hex: 0x002F3B))
                        .opacity(0.8)
                        .cornerRadius(16)
                    //                        .scaleEffect(isActive ? 1 : 0.5)
                )
        }
        .border(Color.green, width: 5)
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
        
        /// **(FACTOR)** |-spacing-| OOOOOOOOOO |-spacing-| **(FACTOR)** |-spacing-| OOOOOOOOOO |-spacing-| ~~(removed factor)~~
        let spacingWidth = C.spacing * 4
        
        /// width for 2 zoom factors and 2 dot views, combined
        /// 2x **(FACTOR)** + 2x OOOOOOOOOO
        let totalContentWidth = availableScreenWidth - rightmostZoomFactorWidth - spacingWidth
        
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
        for zoomFactor in C.zoomFactors {
            var addedWidth = CGFloat(0)
            addedWidth += C.zoomFactorLength
            addedWidth += dotViewWidth(for: zoomFactor)
            addedWidth += C.spacing * 2
            width += addedWidth
        }
        return width
    }
    
    /// have half-screen gap on left side of slider
    func sliderLeftPadding() -> CGFloat {
        let halfAvailableScreenWidth = availableScreenWidth() / 2
        let halfZoomFactorWidth = C.zoomFactorLength / 2
        let padding = halfAvailableScreenWidth - halfZoomFactorWidth
        return padding
    }
    
    /// offset for the active zoom factor
    func activeZoomFactorOffset(for zoomFactor: ZoomFactor) -> CGFloat {
        let position = zoomFactor.positionRange.lowerBound * sliderWidth()
        let currentOffset = savedExpandedOffset + draggingAmount
        
        /// `currentOffset` is negative, make positive, then subtract `position`
        let offset = -currentOffset - position
        return offset
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

