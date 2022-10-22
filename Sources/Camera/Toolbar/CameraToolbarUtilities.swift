//
//  CameraToolbarUtilities.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

extension View {
    func scale(scaleAnimationActive: Binding<Bool>) {
        /// small scale animation
        withAnimation(.spring()) { scaleAnimationActive.wrappedValue = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.toolbarIconDeactivateAnimationDelay) {
            withAnimation(.easeOut(duration: Constants.toolbarIconDeactivateAnimationSpeed)) { scaleAnimationActive.wrappedValue = false }
        }
    }
}

extension View {
    func enabledModifier(isEnabled: Bool, linePadding: CGFloat) -> some View {
        modifier(EnabledModifier(isEnabled: isEnabled, linePadding: linePadding))
    }

    func cameraToolbarIconBackground(toolbarState: ToolbarState) -> some View {
        background(
            VStack {
                if toolbarState == .inTabBar {
                    Color.white.opacity(0.15)
                } else {
                    Color.black.opacity(0.3)
                }
            }
        )
        .cornerRadius(20)
    }
}

struct EnabledModifier: ViewModifier {
    let isEnabled: Bool
    var linePadding: CGFloat
    func body(content: Content) -> some View {
        content
            .opacity(isEnabled ? 1 : 0.5)
            .mask(
                Rectangle()
                    .fill(Color.white)
                    .overlay(
                        LineShape(progress: !isEnabled ? 1 : 0)
                            .stroke(Color.black, style: .init(lineWidth: 5, lineCap: .round))
                    )
                    .compositingGroup()
                    .luminanceToAlpha()
            )
            .overlay(
                LineShape(progress: !isEnabled ? 1 : 0)
                    .stroke(Color.white, style: .init(lineWidth: 2, lineCap: .round))
                    .padding(linePadding)
                    .opacity(!isEnabled ? 1 : 0)
            )
    }
}

struct LineShape: Shape {
    var progress = CGFloat(1)
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX * progress, y: rect.maxY * progress))
        return path
    }
}
