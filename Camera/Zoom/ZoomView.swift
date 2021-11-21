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
    @ObservedObject var zoomViewModel: ZoomViewModel
    let draggingAmount: CGFloat
    let zoomFactor: ZoomFactor
    let index: Int
    
    @GestureState private var isTapped = false
    
    var body: some View {
        let isActive = zoomFactor.zoomRange.contains(zoomViewModel.zoom)
        
        ZoomFactorContent(
            zoomViewModel: zoomViewModel,
            index: index,
            text: isActive ? zoomViewModel.zoom.string : zoomFactor.zoomRange.lowerBound.string
        )
            .scaleEffect(zoomViewModel.isExpanded || isActive ? 1 : 0.7)
            .opacity(!zoomViewModel.isExpanded || isActive ? 1 : 0)
            .offset(x: zoomViewModel.isExpanded && isActive ? zoomViewModel.activeZoomFactorOffset(for: zoomFactor, draggingAmount: draggingAmount) : 0, y: 0)
            .background(
                Button {
                    print("pressed!")
                    //                zoom = value
                } label: {
                    ZoomFactorContent(
                        zoomViewModel: zoomViewModel,
                        index: index,
                        text: zoomFactor.zoomRange.lowerBound.string
                    )
                    .scaleEffect(zoomViewModel.getActivationProgress(for: zoomFactor, draggingAmount: draggingAmount))
                }
                    .opacity(zoomViewModel.isExpanded ? 1 : 0)
            )
    }
}

struct ZoomFactorContent: View {
    @ObservedObject var zoomViewModel: ZoomViewModel
    let index: Int
    let text: String
    
    var body: some View {
        ZStack {
            Color(UIColor(hex: 0x002F3B))
                .opacity(0.8)
                .cornerRadius(24)
            
            Text(text)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(width: C.zoomFactorLength, height: C.zoomFactorLength)
    }
//    
//    func getPadding() -> (CGFloat, CGFloat) {
//        switch index {
//        case 0:
//            return (0, C.zoomFactorPadding / 2)
//        case 1:
//            return (C.zoomFactorPadding / 2, C.zoomFactorPadding / 2)
//        case 2:
//            return (C.zoomFactorPadding / 2, 0)
//        default: fatalError()
//        }
//    }
}



struct ZoomView: View {
    
    @ObservedObject var zoomViewModel: ZoomViewModel
    @GestureState var draggingAmount = CGFloat(0)
    
    
    var body: some View {
        Color.green.overlay(
            Color(UIColor(hex: 0x002F3B))
                .opacity(0.25)
                .frame(width: zoomViewModel.isExpanded ? nil : C.zoomFactorLength * 3 + C.edgePadding * 2, height: C.zoomFactorLength + C.edgePadding * 2)
                .overlay(
                    
                    HStack(spacing: 0) {
                        ForEach(C.zoomFactors.indices, id: \.self) { index in
                            let zoomFactor = C.zoomFactors[index]
                            
                            
                            ZoomFactorView(
                                zoomViewModel: zoomViewModel,
                                draggingAmount: draggingAmount,
                                zoomFactor: zoomFactor,
                                index: index
                            )
                                .zIndex(1)
                            
                            DotSpacerView()
                                .frame(width: zoomViewModel.isExpanded ? zoomViewModel.dotViewWidth(for: zoomFactor) : 0, height: 5)
                                .zIndex(0)
                        }
                    }
                        .frame(width: zoomViewModel.isExpanded ? zoomViewModel.sliderWidth() : nil, alignment: .leading)
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
                                .opacity(zoomViewModel.isExpanded ? 1 : 0)
                        )
                        .offset(x: zoomViewModel.isExpanded ? (zoomViewModel.savedExpandedOffset + draggingAmount + zoomViewModel.sliderLeftPadding()) : 0, y: 0)
                    , alignment: zoomViewModel.isExpanded ? .leading : .center
                )
                .cornerRadius(50)
        )
        
        
            .onAppear {
                zoomViewModel.savedExpandedOffset = -C.zoomFactors[1].positionRange.lowerBound * zoomViewModel.sliderWidth()
                /// This will be from 0 to 1, from slider leftmost to slider rightmost
                let positionInSlider = zoomViewModel.positionInSlider(draggingAmount: draggingAmount)
                zoomViewModel.setZoom(positionInSlider: positionInSlider)
            }
            .highPriorityGesture(
                DragGesture(minimumDistance: 0)
                    .updating($draggingAmount) { value, draggingAmount, transaction in
                        let offset = zoomViewModel.savedExpandedOffset + value.translation.width
                        
                        if offset >= 0 {
                            draggingAmount = 0
                            DispatchQueue.main.async { zoomViewModel.savedExpandedOffset = 0 }
                        } else if -offset >= zoomViewModel.sliderWidth() {
                            draggingAmount = 0
                            DispatchQueue.main.async { zoomViewModel.savedExpandedOffset = -zoomViewModel.sliderWidth() }
                        } else {
                            draggingAmount = value.translation.width
                        }
                        
                        
                        if offset < 0 && -offset < zoomViewModel.sliderWidth() {
                            draggingAmount = value.translation.width
                        }
                        /// This will be from 0 to 1, from slider leftmost to slider rightmost
                        let positionInSlider = zoomViewModel.positionInSlider(draggingAmount: draggingAmount)
                        zoomViewModel.setZoom(positionInSlider: positionInSlider)
                        
                        if !zoomViewModel.gestureStarted {
                            DispatchQueue.main.async {
                                zoomViewModel.keepingExpandedUUID = UUID()
                                zoomViewModel.gestureStarted = true
                            }
                        }
                        
                        if !zoomViewModel.isExpanded {
                            DispatchQueue.main.async {
                                withAnimation {
                                    zoomViewModel.isExpanded = true
                                }
                            }
                        }
                    }
                    .onEnded { value in
                        let offset = zoomViewModel.savedExpandedOffset + value.translation.width
                        if offset >= 0 {
                            zoomViewModel.savedExpandedOffset = 0
                        } else if -offset >= zoomViewModel.sliderWidth() {
                            zoomViewModel.savedExpandedOffset = -zoomViewModel.sliderWidth()
                        } else {
                            zoomViewModel.savedExpandedOffset += value.translation.width
                        }
                        /// This will be from 0 to 1, from slider leftmost to slider rightmost
                        let positionInSlider = zoomViewModel.positionInSlider(draggingAmount: draggingAmount)
                        zoomViewModel.setZoom(positionInSlider: positionInSlider)
                        
                        zoomViewModel.gestureStarted = false
                        let uuidToCheck = zoomViewModel.keepingExpandedUUID
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            
                            /// make sure another swipe hasn't happened yet
                            if uuidToCheck == zoomViewModel.keepingExpandedUUID {
                                zoomViewModel.keepingExpandedUUID = nil
                                withAnimation {
                                    zoomViewModel.isExpanded = false
                                }
                            }
                        }
                    }
            )
    }
}

struct ZoomView_Previews: PreviewProvider {
    static var previews: some View {
        ZoomView(zoomViewModel: ZoomViewModel())
            .frame(maxWidth: .infinity)
            .padding(50)
            .background(Color.gray)
    }
}

