//
//  SnapshotView.swift
//  Camera
//
//  Created by Zheng on 12/2/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

struct SnapshotConstants {
    static var checkStartTrim = CGFloat(0.675)
}
struct SnapshotView: View {
    @State var scaleAnimationActive = true
    @State var done = true
    @State var startTrim = CGFloat(0)
    @State var endTrim = SnapshotConstants.checkStartTrim
    
    var body: some View {
        Button {
            
            /// small scale animation
            withAnimation(.spring()) { scaleAnimationActive = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                withAnimation(.easeOut(duration: 0.3)) { scaleAnimationActive = false }
            }
            
            done.toggle()
            if done {
                withAnimation(
                    .spring()
                ) {
                    startTrim = SnapshotConstants.checkStartTrim
                    endTrim = CGFloat(1)
                }
            } else {
                withAnimation(
                    .spring()
                ) {
                    startTrim = CGFloat(0)
                    endTrim = SnapshotConstants.checkStartTrim
                }
            }
        } label: {
            VStack {
                Image("CameraRim")
                    .overlay(
                        CameraInnerShape()
                            .trim(from: startTrim, to: endTrim)
                            .stroke(
                                Color.white,
                                style: .init(
                                    lineWidth: 1.5,
                                    lineCap: .round,
                                    lineJoin: .round
                                )
                            )
                            .padding(EdgeInsets(top: 6, leading: 6, bottom: 4, trailing: 6))
                    )
            }
                .scaleEffect(scaleAnimationActive ? 1.2 : 1)
                .frame(width: 40, height: 40)
                .foregroundColor(.white)
                .font(.system(size: 19))
                .background(
                    Color.white.opacity(0.15)
                )
                .cornerRadius(20)
        }
        .onAppear {
            if done {
                withAnimation(.easeOut(duration: 0.5)) {
                    startTrim = SnapshotConstants.checkStartTrim
                    endTrim = CGFloat(1)
                }
            } else {
                withAnimation(.easeOut(duration: 0.5)) {
                    startTrim = CGFloat(0)
                    endTrim = SnapshotConstants.checkStartTrim
                }
            }
        }
    }
    
}
struct CameraInnerShape: Shape {
    var progress = CGFloat(1)
    var animatableData: CGFloat {
        get { progress }
        set { self.progress = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
//        let circleLength = CGFloat(8)
        let circleRadius = CGFloat(4)
//        let circleRect = CGRect(
//            x: rect.width / 2 - circleLength / 2,
//            y: rect.height / 2 - circleLength / 2,
//            width: circleLength,
//            height: circleLength
//        )
//        path.addEllipse(in: circleRect)
        
        let circleCenter = CGPoint(x: rect.width / 2, y: rect.height / 2)

        path.addArc(
            center: circleCenter,
            radius: circleRadius,
            startAngle: .degrees(179.999999),
            endAngle: .degrees(180),
            clockwise: true
        )
        
        let checkStartX = rect.width / 2 - 4
        let checkMidX = rect.width / 2 - 0.95
        let checkEndX = rect.width / 2 + 4
        path.move(to: CGPoint(x: checkStartX, y: rect.midY))
        path.addLine(to: CGPoint(x: checkMidX, y: rect.maxY - 1.2))
        path.addLine(to: CGPoint(x: checkEndX, y: rect.minY + 0.5))
        return path
    }
}

struct SnapshotViewTester: View {
    var body: some View {
        SnapshotView()
    }
}
struct SnapshotView_Previews: PreviewProvider {
    static var previews: some View {
        SnapshotViewTester()
            .padding()
            .background(Color.blue)
            .scaleEffect(4)
            .previewLayout(.fixed(width: 200, height: 200))
    }
}
