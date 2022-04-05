//
//  SettingsHighlightsIcon.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/5/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct SettingsHighlightsIcon: View {
    @ObservedObject var model: SettingsViewModel
    var body: some View {
        let color = UIColor(hex: UInt(model.highlightsColor))

        color.color
            .opacity(model.highlightsBackgroundOpacity)
            .cornerRadius(SettingsConstants.iconCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: SettingsConstants.iconCornerRadius)
                    .strokeBorder(color.color, lineWidth: model.highlightsBorderWidth)
            )
            .frame(width: SettingsConstants.iconSize.width, height: SettingsConstants.iconSize.height)
    }
}
