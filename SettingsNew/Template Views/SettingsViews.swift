//
//  SettingsViews.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct SettingsButton<Content: View>: View {
    let action: () -> Void
    @ViewBuilder let content: Content

    var body: some View {
        Button(action: action) {
            content
        }
        .buttonStyle(SettingsButtonStyle())
    }
}

struct SettingsButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
            .background(
                UIColor.label.withAlphaComponent(0.1).color
                    .opacity(
                        getBackgroundOpacity(isPressed: configuration.isPressed)
                    )
            )
    }

    func getBackgroundOpacity(isPressed: Bool) -> Double {
        return isPressed ? 1 : 0
    }
}

extension View {
    func settingsSmallTextStyle() -> some View {
        font(.system(.subheadline))
            .multilineTextAlignment(.leading)
            .foregroundColor(UIColor.secondaryLabel.color)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, SettingsConstants.rowHorizontalInsets.leading) /// extra padding
    }

    func settingsHeaderStyle() -> some View {
        settingsSmallTextStyle()
            .padding(.bottom, SettingsConstants.headerBottomPadding)
    }

    func settingsDescriptionStyle() -> some View {
        settingsSmallTextStyle()
            .padding(.top, SettingsConstants.descriptionTopPadding)
    }
}
