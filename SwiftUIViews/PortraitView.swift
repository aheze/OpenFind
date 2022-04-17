//
//  PortraitView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/17/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

enum SettingsProfileTransformState: CaseIterable {
    case flippedVertically
    case flippedHorizontally
    case zoomed
    case spun
}

struct PortraitView: View {
    var length: CGFloat
    var circular: Bool
    @Binding var transform: SettingsProfileTransformState?

    var body: some View {
        if circular {
            Image("Zheng")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaleEffect(transform == .zoomed ? 2 : 1)
                .frame(width: length, height: length)
                .clipShape(Circle())
                .roundedCircleBorder(borderRadius: 6)
                .rotation3DEffect(
                    .degrees(transform == .flippedHorizontally || transform == .flippedVertically ? 180 : 0),
                    axis: (x: transform == .flippedVertically ? 1 : 0, y: transform == .flippedHorizontally ? 1 : 0, z: 0)
                )
                .rotationEffect(.degrees(transform == .spun ? 90 : 0))
        } else {
            Image("Zheng")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaleEffect(transform == .zoomed ? 2 : 1)
                .frame(width: length, height: length)
                .clipped()
                .border(Color.black, width: 3)
                .rotation3DEffect(
                    .degrees(transform == .flippedHorizontally || transform == .flippedVertically ? 180 : 0),
                    axis: (x: transform == .flippedVertically ? 1 : 0, y: transform == .flippedHorizontally ? 1 : 0, z: 0)
                )
                .rotationEffect(.degrees(transform == .spun ? 90 : 0))
        }
    }
}

extension View {
    func roundedCircleBorder(borderRadius: CGFloat) -> some View {
        self.clipShape(Circle())
            .overlay(
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                UIColor.systemBackground.toColor(Colors.accent, percentage: 0.1).color,
                                UIColor.systemBackground.toColor(Colors.accent, percentage: 0.25).color
                            ],
                            startPoint: .bottom,
                            endPoint: .top
                        ),
                        lineWidth: borderRadius
                    )
            )
            .shadow(
                color: UIColor.label.toColor(Colors.accent, percentage: 0.25).color.opacity(0.25),
                radius: borderRadius,
                x: 0,
                y: borderRadius / 2
            )
    }
}
