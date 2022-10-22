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

    @State var highlightSize = CGSize.zero
    let highlightSidePadding = CGFloat(3.5)

    var body: some View {
        let color = UIColor(hex: UInt(realmModel.highlightsColor))

        HStack(spacing: 0) {
            Text("What if you could ")
            Text("find")
                .sizeReader {
                    highlightSize = $0
                }
                .overlay(
                    color.color
                        .opacity(realmModel.highlightsBackgroundOpacity)
                        .cornerRadius(SettingsConstants.iconCornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: SettingsConstants.iconCornerRadius)
                                .strokeBorder(color.color, lineWidth: realmModel.highlightsBorderWidth)
                        )
                        .padding(-realmModel.getHighlightPadding(size: highlightSize) * 0.7) /// preview a bit smaller
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
            .padding(.vertical, -50) /// allow vertical overflow of the padding
        )
    }
}
