//
//  SettingsCredits.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/6/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

enum SettingsProfileTransformState: CaseIterable {
    case flippedVertically
    case flippedHorizontally
    case zoomed
    case spun
}

struct SettingsCredits: View {
    @ObservedObject var model: SettingsViewModel
    @ObservedObject var realmModel: RealmModel
    @State var transform: SettingsProfileTransformState?

    var body: some View {
        VStack(spacing: 20) {
            Button {
                withAnimation(
                    .spring(
                        response: 0.6,
                        dampingFraction: 0.6,
                        blendDuration: 1
                    )
                ) {
                    if transform == nil {
                        transform = SettingsProfileTransformState.allCases.randomElement()
                    } else {
                        transform = nil
                    }
                }
            } label: {
                Image("Zheng")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(transform == .zoomed ? 2 : 1)
                    .frame(width: 180, height: 180)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        UIColor.systemBackground.color,
                                        UIColor.systemBackground.toColor(.label, percentage: 0.1).color,
                                    ],
                                    startPoint: .bottom,
                                    endPoint: .top
                                ),
                                lineWidth: 6
                            )
                    )
                    .shadow(
                        color: UIColor.label.color.opacity(0.25),
                        radius: 6,
                        x: 0,
                        y: 3
                    )
                    .rotation3DEffect(
                        .degrees(transform == .flippedHorizontally || transform == .flippedVertically ? 180 : 0),
                        axis: (x: transform == .flippedVertically ? 1 : 0, y: transform == .flippedHorizontally ? 1 : 0, z: 0)
                    )
                    .rotationEffect(.degrees(transform == .spun ? 90 : 0))
            }
            .buttonStyle(SettingsProfileButtonStyle())

            Text("Find by Andrew Zheng")
                .font(UIFont.preferredCustomFont(forTextStyle: .title3, weight: .medium).font)
        }
    }
}

struct SettingsProfileButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(
                .spring(
                    response: 0.3,
                    dampingFraction: 0.4,
                    blendDuration: 1
                ),
                value: configuration.isPressed
            )
    }
}
