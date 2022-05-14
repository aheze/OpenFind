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
    @ObservedObject var realmModel: RealmModel
    
    var body: some View {
        let color = UIColor(hex: UInt(realmModel.highlightsColor))

        color.color
            .opacity(realmModel.highlightsBackgroundOpacity)
            .cornerRadius(SettingsConstants.iconCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: SettingsConstants.iconCornerRadius)
                    .strokeBorder(color.color, lineWidth: realmModel.highlightsBorderWidth)
            )
            .frame(width: SettingsConstants.iconSize.width, height: SettingsConstants.iconSize.height)
    }
}
