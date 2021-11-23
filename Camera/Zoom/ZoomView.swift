//
//  ZoomView.swift
//  Camera
//
//  Created by Zheng on 11/19/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

struct DotSpacerView: View {
    var numberOfDots: Int
    var body: some View {
        Color.clear.overlay(
            HStack(spacing: 0) {
                ForEach(0..<numberOfDots, id: \.self) { _ in
                    HStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 5, height: 5)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
                .drawingGroup()
                .opacity(0.5)
        )
            .clipped()
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
        
        /// projection to center
        Button(action: activate) {
            ZoomFactorContent(
                zoomViewModel: zoomViewModel,
                index: index,
                text: isActive ? zoomViewModel.zoomLabel.string : zoomFactor.zoomLabelRange.lowerBound.string,
                isActive: isActive
            )
        }
        .disabled(isActive || !zoomViewModel.allowingButtonPresses) /// only press-able when not already pressed
        .scaleEffect(
            zoomViewModel.isExpanded && !isActive ? zoomFactor.activationProgress : 1
        )
        .opacity(
            zoomViewModel.isExpanded && !isActive ? zoomFactor.activationProgress : 1
        )
        .scaleEffect(isActive ? 1 : 0.7)
        .offset(x: zoomViewModel.isExpanded && isActive ? zoomViewModel.activeZoomFactorOffset(for: zoomFactor, totalOffset: draggingAmount + zoomViewModel.savedExpandedOffset) : 0, y: 0)
        
        /// stays where it is supposed to be, moves with the slider
        .background(
            Button(action: activate) {
                ZoomFactorContent(
                    zoomViewModel: zoomViewModel,
                    index: index,
                    text: zoomFactor.zoomLabelRange.lowerBound.string,
                    isActive: false
                )
            }
                .scaleEffect(zoomFactor.activationProgress)
                .opacity(zoomFactor.activationProgress)
                .scaleEffect(0.7)
                .opacity(isActive && zoomViewModel.isExpanded ? 1 : 0) /// show when passed preset and dragging left, increasing zoom value
                .disabled(!zoomViewModel.allowingButtonPresses)
        )
    }
    
    func activate() {
        withAnimation {
            zoomViewModel.zoom = zoomFactor.zoomRange.lowerBound
            zoomViewModel.zoomLabel = zoomFactor.zoomLabelRange.lowerBound
            zoomViewModel.savedExpandedOffset = -zoomFactor.positionRange.lowerBound * zoomViewModel.sliderWidth
            zoomViewModel.updateActivationProgress(positionInSlider: zoomViewModel.positionInSlider(totalOffset: zoomViewModel.savedExpandedOffset))
            zoomViewModel.isExpanded = false
            zoomViewModel.keepingExpandedUUID = nil
        }
    }
}

struct ZoomFactorContent: View {
    @ObservedObject var zoomViewModel: ZoomViewModel
    let index: Int
    let text: String
    let isActive: Bool
    
    var body: some View {
        ZStack {
            Color(UIColor(hex: 0x002F3B))
                .opacity(isActive ? 0.9 : 0.5)
                .cornerRadius(24)
            
            Text(text)
                .font(.system(size: 16, weight: isActive ? .semibold : .medium))
                .foregroundColor(isActive ? Color(Constants.activeIconColor) : .white)
        }
        .frame(width: C.zoomFactorLength, height: C.zoomFactorLength)
    }
}

struct ZoomView: View {
    
    @ObservedObject var zoomViewModel: ZoomViewModel
    @GestureState var draggingAmount = CGFloat(0)
    
    
    var body: some View {
        Color.clear.overlay(
            Color(UIColor(hex: 0x002F3B))
                .opacity(0.15)
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
                            
                            DotSpacerView(numberOfDots: Int(zoomViewModel.dotViewWidth(for: zoomFactor)) / 12)
                                .frame(width: zoomViewModel.isExpanded ? zoomViewModel.dotViewWidth(for: zoomFactor) : 0, height: 30)
                                .zIndex(0)
                        }
                    }
                        .frame(width: zoomViewModel.isExpanded ? zoomViewModel.sliderWidth : nil, alignment: .leading)
                        .offset(x: zoomViewModel.isExpanded ? (zoomViewModel.savedExpandedOffset + draggingAmount + zoomViewModel.sliderLeftPadding) : 0, y: 0)
                    , alignment: zoomViewModel.isExpanded ? .leading : .center
                )
                .cornerRadius(50)
                .padding(.horizontal, C.containerEdgePadding)
                .opacity(zoomViewModel.ready ? 1 : 0)
        )
            .simultaneousGesture(
                
                /// if expanded, immediately keep expanded
                /// if not, wait 0.3 seconds
                LongPressGesture(minimumDuration: zoomViewModel.isExpanded ? 0 : 0.5, maximumDistance: .infinity)
                    .onEnded { _ in /// touched down
                        zoomViewModel.expand()
                    }
                    .simultaneously( /// to cancel button presses after too long
                        with:
                            LongPressGesture(minimumDuration: 0.6, maximumDistance: .infinity)
                            .onEnded { _ in
                                zoomViewModel.stopButtonPresses()
                            }
                    )
                    .sequenced( /// if the user pressed down and up without dragging
                        before:
                            TapGesture()
                            .onEnded { _ in
                                zoomViewModel.startTimeout()
                            }
                                   )
                    .simultaneously( /// normal drag gesture
                        with:
                            DragGesture(minimumDistance: 2)
                            .updating($draggingAmount) { value, draggingAmount, transaction in
                                zoomViewModel.stopButtonPresses()
                                zoomViewModel.update(translation: value.translation.width, ended: false) { newSavedExpandedOffset, newTranslation in
                                    DispatchQueue.main.async {
                                        zoomViewModel.savedExpandedOffset = newSavedExpandedOffset
                                    }
                                    draggingAmount = newTranslation
                                }
                            }
                            .onEnded { value in
                                zoomViewModel.update(translation: value.translation.width, ended: true) { newSavedExpandedOffset, _ in
                                    
                                    /// `DispatchQueue` is important! Otherwise, if going too fast, offset won't update.
                                    DispatchQueue.main.async {
                                        zoomViewModel.savedExpandedOffset = newSavedExpandedOffset
                                    }
                                }
                                zoomViewModel.startTimeout()
                            }
                    )
                
            )
    }
}

struct ZoomView_Previews: PreviewProvider {
    static var previews: some View {
        ZoomView(zoomViewModel: ZoomViewModel(containerView: UIView()))
            .frame(maxWidth: .infinity)
            .padding(50)
            .background(Color.gray)
    }
}

