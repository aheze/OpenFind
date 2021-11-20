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
    static var edgePadding = CGFloat(0)
    static var buttonLength = CGFloat(80)
    static var spacing = CGFloat(0)
    
    static let minZoom = CGFloat(0.5)
    static let maxZoom = CGFloat(10)
    
    static let zoomRanges = [
        ZoomFactor(range: minZoom..<1, positionRange: 0..<0.25),
        ZoomFactor(range: 1..<2, positionRange: 0.25..<0.5),
        ZoomFactor(range:2..<maxZoom, positionRange: 0.5..<1),
    ]
}
struct ZoomFactor: Hashable {
    var range: Range<CGFloat>
    var positionRange: Range<CGFloat> /// position relative to entire slider
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
            .border(Color.red, width: 5)
        
    }
}
struct ZoomView: View {
    @State var zoom: CGFloat = 1
    @GestureState var dragAmount = CGFloat(0)
    
    @State var isExpanded = true
    @State var expandedOffset = CGFloat(0)
    
    @State var gestureStarted = false
    @State var keepingExpandedUUID: UUID?
    
    var body: some View {
        Color.clear.overlay(
            HStack(spacing: C.spacing) {
                ForEach(C.zoomRanges, id: \.self) { zoomRange in
                    ZoomPresetView(zoom: $zoom, value: zoomRange.range.lowerBound, isActive: zoomRange.range.contains(zoom))
                    
                    DotView()
                        .frame(width: isExpanded ? dotViewWidth(for: zoomRange) : 0)
                }
            }
                .padding(.vertical, 10)
                .background(
                    HStack(spacing: C.spacing) {
                        ForEach(0...C.zoomRanges.count, id: \.self) { index in
                            Color.blue
                                .frame(width: sliderWidth() / 4)
                                .border(Color.white, width: 3)
                        }
                    }
                    , alignment: .leading
                )
            
                .frame(width: isExpanded ? sliderWidth() : nil, alignment: .leading)
                .border(Color.cyan, width: 3)
                .clipped()
                .offset(x: isExpanded ? (expandedOffset + dragAmount + originalLeftOffset()) : 0, y: 0)
            , alignment: .leading)
            .padding(C.edgePadding)
            .background(
                Color(UIColor(hex: 0x002F3B))
//                    .opacity(0.25)
            )
            .cornerRadius(50)
            .onAppear {
                //                expandedOffset = -(originalLeftOffset() + getPositionOfZoomFactor(for: 1))
                //                expandedOffset = -getPositionOfZoomFactor(for: 1) - originalLeftOffset()
                print("Origi exp: \(expandedOffset)")
            }
            .highPriorityGesture(
                DragGesture(minimumDistance: 0)
                    .updating($dragAmount) { value, dragAmount, transaction in
                        dragAmount = value.translation.width
                        let draggingProgress = expandedOffset + dragAmount
                        let sliderTotalTrackWidth = sliderWidth()
                        let fraction = -draggingProgress / sliderTotalTrackWidth
                        
                        print("Frac: \(fraction)")
                        
                        if let zoomFactor = C.zoomRanges.first(where: { $0.positionRange.contains(fraction) }) {
                            
                            let positionRangeLower = zoomFactor.positionRange.lowerBound
                            let positionRangeUpper = zoomFactor.positionRange.upperBound
                            let zoomPositionInRange = fraction - positionRangeLower
                            let zoomFractionOfPositionRange = zoomPositionInRange / (positionRangeUpper - positionRangeLower)
                            
                            let zoomRange = zoomFactor.range.upperBound - zoomFactor.range.lowerBound
                            let zoom = zoomFactor.range.lowerBound + zoomFractionOfPositionRange * zoomRange
                            DispatchQueue.main.async {
                                self.zoom = zoom
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.zoom = 0
                            }
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
                .frame(width: C.buttonLength, height: C.buttonLength)
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
    func availableScreenWidth() -> CGFloat {
        let totalWidth = UIScreen.main.bounds.width - (C.edgePadding * 2)
        return totalWidth
    }
    
    func dotViewWidth(for zoomFactor: ZoomFactor) -> CGFloat {
        let availableScreenWidth = availableScreenWidth()
        
        
        let rightFactorWidth = C.buttonLength
        let spacingWidth = C.spacing * 4
        let availableWidth = availableScreenWidth - rightFactorWidth - spacingWidth
        let usedWidth = availableWidth / 2 /// divide by 2, because each DotView is only half of the screen
        
        let normalWidthFactor = 0.25
        let widthFactor = (zoomFactor.positionRange.upperBound - zoomFactor.positionRange.lowerBound) / normalWidthFactor
        let width = (usedWidth * widthFactor) - C.buttonLength
        
        return width
    }
    
    func sliderWidth() -> CGFloat {
        
        var width = CGFloat(0)
        for zoomFactor in C.zoomRanges {
            var addedWidth = CGFloat(0)
            addedWidth += C.buttonLength
            addedWidth += dotViewWidth(for: zoomFactor)
            addedWidth += C.spacing * 2
            width += addedWidth
        }
        //        width += C.buttonLength / 2
        //        width -= (C.buttonLength / 2) /// there is no button at the far right, this is to prevent fraction progress getting too big
        return width
    }
    func originalLeftOffset() -> CGFloat {
        let leftTotalWidth = (UIScreen.main.bounds.width / 2) - C.edgePadding
        let leftButtonWidth = C.buttonLength / 2
        let total = leftTotalWidth - leftButtonWidth - C.spacing
        return total
    }
    //    func getPositionOfZoomFactor(for zoomFactor: Double) -> CGFloat {
    //        if let zoomFactor = C.zoomRanges.first(where: { $0.range.lowerBound == zoomFactor }) {
    //            let position = zoomFactor.positionPercentage * sliderWidth()
    //            return position
    //        }
    //        return 0
    //    }
}

struct ZoomView_Previews: PreviewProvider {
    static var previews: some View {
        ZoomView()
            .frame(maxWidth: .infinity)
            .padding(50)
            .background(Color.gray)
    }
}

