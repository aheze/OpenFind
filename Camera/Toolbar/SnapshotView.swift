//
//  SnapshotView.swift
//  Camera
//
//  Created by Zheng on 12/2/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

struct SnapshotConstants {
    static var checkStartTrim = CGFloat(0.675) /// I guessed this number - it's the percentage where the circle becomes the checkmark
}

struct SnapshotView: View {
    @Binding var done: Bool
    @State var scaleAnimationActive = false /// scale up/down animation flag
    @State var startTrim = CGFloat(0)
    @State var endTrim = SnapshotConstants.checkStartTrim
    
    var body: some View {
        Button {
            /// small scale animation
            withAnimation(.spring()) { scaleAnimationActive = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.toolbarIconDeactivateAnimationDelay) {
                withAnimation(.easeOut(duration: Constants.toolbarIconDeactivateAnimationSpeed)) { scaleAnimationActive = false }
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
                withAnimation(.easeOut(duration: Constants.toolbarIconDeactivateAnimationSpeed)) {
                    startTrim = CGFloat(0)
                    endTrim = SnapshotConstants.checkStartTrim
                }
            }
        } label: {
            VStack {
                Image("CameraRim") /// wim of camera
                    .foregroundColor(done ? Color(Constants.activeIconColor) : .white)
                    .overlay(
                        CameraInnerShape()
                            .trim(from: startTrim, to: endTrim)
                            .stroke(
                                done ? Color(Constants.activeIconColor) : .white,
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
    }
}

struct CameraInnerShape: Shape {
    var progress = CGFloat(1)
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let circleRadius = CGFloat(4)
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
    @State var done = false
    var body: some View {
        SnapshotView(done: $done)
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