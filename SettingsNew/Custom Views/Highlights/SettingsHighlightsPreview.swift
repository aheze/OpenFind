//
//  SettingsHighlightsPreview.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/5/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct SettingsHighlightsPreview: View {
    @ObservedObject var model: SettingsViewModel
    @ObservedObject var realmModel: RealmModel

    let highlightSidePadding = CGFloat(4.5)

    var body: some View {
        let color = UIColor(hex: UInt(realmModel.highlightsColor))

        HStack(spacing: 0) {
            Text("What if you could ")
            Text("find")
                .overlay(
                    color.color
                        .opacity(realmModel.highlightsBackgroundOpacity)
                        .cornerRadius(SettingsConstants.iconCornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: SettingsConstants.iconCornerRadius)
                                .strokeBorder(color.color, lineWidth: realmModel.highlightsBorderWidth)
                        )
                        .padding(-highlightSidePadding)
                )
            Text(" text in real life?")
        }
        .accessibilityElement(children: .combine)
        .font(UIFont.preferredFont(forTextStyle: .title3).font)
        .fixedSize(horizontal: true, vertical: false)
        .padding(.vertical, highlightSidePadding)
        .mask(
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .white, location: 0.3),
                    .init(color: .white, location: 0.7),
                    .init(color: .clear, location: 1)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
}
