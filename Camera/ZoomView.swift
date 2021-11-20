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

struct ZoomView: View {
    @State var zoom: CGFloat = 1
    @GestureState var dragAmount = CGSize.zero
    
    @State var isExpanded = false
    
    @State var gestureStarted = false
    @State var keepingExpandedUUID: UUID?
    

    
    var body: some View {
        HStack {
            ZoomPresetView(zoom: $zoom, value: 0.5, isActive: zoom == 0.5)
            
            Spacer()
                .frame(maxWidth: isExpanded ? .infinity : 0)
            
            ZoomPresetView(zoom: $zoom, value: 1, isActive: zoom == 1)
            
            Spacer()
                .frame(maxWidth: isExpanded ? .infinity : 0)
            
            ZoomPresetView(zoom: $zoom, value: 2, isActive: zoom == 2)
        }
        .padding(4)
        .background(
            Color(UIColor(hex: 0x002F3B))
                .opacity(0.25)
        )
        .cornerRadius(50)
        .highPriorityGesture(
            DragGesture()
                .updating($dragAmount) { value, state, transaction in
                    state = value.translation
                    
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
                .frame(width: 32, height: 32)
                .scaleEffect(isActive ? 1 : 0.7)
                .background(
                    Color(UIColor(hex: 0x002F3B))
                        .opacity(0.5)
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
