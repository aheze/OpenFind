//
//  ZoomView.swift
//  Camera
//
//  Created by Zheng on 11/19/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

extension CGFloat {
    var clean: String {
        let double = Double(self)
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(double)
    }
}
extension Double {
    func truncate(places : Int)-> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}
extension CGFloat {
    var string: String {
        let value = Double(self).truncate(places: 1)
        return "\(value)"
    }
}
struct C {
    static var edgePadding = CGFloat(10)
    static var buttonLength = CGFloat(32)
    static var spacing = CGFloat(2)
    
    static let minZoom = CGFloat(0.5)
    static let maxZoom = CGFloat(10)
    
   
//    static let zoomRanges = [
//        0.5: minZoom..<1,
//        1: 1..<2,
//        2: 2..<maxZoom,
//    ]
    static let zoomRanges = [
        ZoomFactor(value: 0.5, range: minZoom..<1, positionPercentage: 0, widthPercentage: 0.25),
        ZoomFactor(value: 1, range: 1..<2, positionPercentage: 0.25, widthPercentage: 0.25),
        ZoomFactor(value: 2, range:2..<maxZoom, positionPercentage: 0.5, widthPercentage: 0.5),
    ]
}
struct ZoomFactor: Hashable {
    var value: Double
    var range: Range<CGFloat>
    var positionPercentage: CGFloat /// position relative to entire slider
    var widthPercentage: CGFloat
}

struct DotView: View {
    var body: some View {
        Color.blue.opacity(0.8).background(
            HStack {
                ForEach(0..<25) { _ in
                    Circle()
                        .fill(Color.white)
                        .frame(width: 5, height: 5)
                }
            }
        )
            .drawingGroup() /// make sure circles don't disappear
            .clipped()
        
    }
}
struct ZoomView: View {
    @State var zoom: CGFloat = 1
    @GestureState var dragAmount = CGSize.zero
    
    
    @State var isExpanded = false
    
    @State var expandedOffset = CGFloat(0)
    
    @State var gestureStarted = false
    @State var keepingExpandedUUID: UUID?
    
    func dotViewWidth(for zoomFactor: ZoomFactor) -> CGFloat {
        let totalWidth = sliderWidth()
        let dotWidthPercentage = zoomFactor.widthPercentage
        let width = totalWidth * dotWidthPercentage
        return width
    }
    func sliderWidth() -> CGFloat {
        let totalWidth = UIScreen.main.bounds.width - (C.edgePadding * 2)
        let numberOfPresets = CGFloat(C.zoomRanges.count)
        let interPresetSpacing = (numberOfPresets - 1) * C.spacing * 2 /// times 2 because both sides of Dot has spacing
        let presetLengths = (C.buttonLength * numberOfPresets)
        let availableWidth = totalWidth - interPresetSpacing - presetLengths
        let dotViewWidth = availableWidth / (numberOfPresets - 1)
        
        let dotViewWidthTotal = dotViewWidth * 4
        let total = presetLengths + dotViewWidthTotal + interPresetSpacing
        
        return total
        
    }
    func sliderLeftWidth() -> CGFloat {
        let leftTotalWidth = (UIScreen.main.bounds.width / 2) - C.edgePadding
        let leftButtonWidth = C.buttonLength / 2
        let total = leftTotalWidth - leftButtonWidth - C.spacing
        
        return total
        
    }
    func getPositionOfZoomFactor(for zoomFactor: Double) {
        
    }
    func getOffset(for zoomFactor: Double) -> CGFloat {
        if let zoomRange = C.zoomRanges.first(where: { $0.value == zoomFactor }) {
            if isExpanded && zoomRange.range.contains(zoom) {
                
                let offset = -(expandedOffset + dragAmount.width)
                
                print("Offset for \(zoomFactor) is \(offset)")
                return offset
            }
        }
        return 0
    }
    
    
    var body: some View {
        Color.clear.overlay(
            HStack(spacing: C.spacing) {
                ForEach(C.zoomRanges, id: \.self) { zoomRange in
                    ZoomPresetView(zoom: $zoom, value: zoomRange.value, isActive: zoom == zoomRange.value)
                    
                    DotView()
                        .frame(width: isExpanded ? dotViewWidth(for: zoomRange) : 0)
                }
                
//                ZoomPresetView(zoom: $zoom, value: 0.5, isActive: zoom == 0.5)
//                    .offset(x: getOffset(for: 0.5), y: 0)
//
//                DotView()
//                    .frame(width: isExpanded ? dotViewWidth() : 0)
//
//                ZoomPresetView(zoom: $zoom, value: 1, isActive: zoom == 1)
//                    .offset(x: getOffset(for: 1), y: 0)
//
//                DotView()
//                    .frame(width: isExpanded ? dotViewWidth() : 0)
//
//                ZoomPresetView(zoom: $zoom, value: 2, isActive: zoom == 2)
//                    .offset(x: getOffset(for: 2), y: 0)
//
//                DotView()
//                    .frame(width: isExpanded ? dotViewWidth() * 2 : 0)
            }
                .frame(width: isExpanded ? sliderWidth() : nil)
                .offset(x: isExpanded ? (expandedOffset + dragAmount.width) : 0, y: 0)
        )
            .padding(C.edgePadding)
            .background(
                Color(UIColor(hex: 0x002F3B))
                    .opacity(0.25)
            )
            .cornerRadius(50)
            .highPriorityGesture(
                DragGesture()
                    .updating($dragAmount) { value, state, transaction in
                        state = value.translation
                        
                        let progress = -(expandedOffset + state.width - sliderLeftWidth())
                        //                        print("Prog: \(progress)")
                        let sliderTotalTrackWidth = sliderWidth()
                        //
                        //
                        let fraction = progress / sliderTotalTrackWidth
//                        print("frac: \(fraction)")
                        let zoom = C.minZoom + fraction * (C.maxZoom - C.minZoom)
//                        print("zoom: \(zoom)")
                        
                        DispatchQueue.main.async {
                            self.zoom = zoom
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
                        expandedOffset += value.translation.width
                        
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
                .frame(width: C.buttonLength, height: C.buttonLength)
                .scaleEffect(isActive ? 1 : 0.7)
                .background(
                    Color(UIColor(hex: 0x002F3B))
                        .opacity(0.2)
                        .cornerRadius(16)
                        .scaleEffect(isActive ? 1 : 0.8)
                )
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
