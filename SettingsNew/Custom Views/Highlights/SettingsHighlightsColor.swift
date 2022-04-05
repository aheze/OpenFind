//
//  SettingsHighlightsColor.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/5/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct SettingsHighlightsColor: View {
    @ObservedObject var model: SettingsViewModel

    //    @ObservedObject var colorPickerModel = ColorPickerViewModel()

    var body: some View {
        let color = UIColor(hex: UInt(model.highlightsColor))

        HStack {
            Text("Default Color")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(SettingsConstants.rowVerticalInsetsFromText)

            Button {
                model.showHighlightColorPicker?()
            } label: {
                Circle()
                    .fill(color.color)
                    .shadow(
                        color: UIColor.label.color.opacity(0.5),
                        radius: 2,
                        x: 0,
                        y: 1
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        UIColor.systemBackground.color,
                                        UIColor.systemBackground.toColor(.label, percentage: 0.1).color,
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                    )
                    .frame(width: 30, height: 30)
            }
        }
        .padding(SettingsConstants.rowHorizontalInsets)
    }
}
