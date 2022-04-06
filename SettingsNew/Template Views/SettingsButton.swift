//
//  SettingsButton.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct SettingsButton: View {
    @ObservedObject var model: SettingsViewModel
    @ObservedObject var realmModel: RealmModel
    var title: String
    var rightIconName: String?
    var action: (() -> Void)?

    var body: some View {
        SettingsRowButton {
            action?()
        } content: {
            HStack(spacing: SettingsConstants.rowIconTitleSpacing) {
                Text(title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(SettingsConstants.rowVerticalInsetsFromText)

                if let rightIconName = rightIconName {
                    Image(systemName: rightIconName)
                        .foregroundColor(UIColor.secondaryLabel.color)
                }
            }
            .padding(SettingsConstants.rowHorizontalInsets)
        }
    }
}
