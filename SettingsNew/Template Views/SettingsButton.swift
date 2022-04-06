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
    var tintColor: UIColor?
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
                        .foregroundColor(tintColor?.color ?? UIColor.secondaryLabel.color)
                }
            }
            .foregroundColor(tintColor?.color)
            .padding(SettingsConstants.rowHorizontalInsets)
        }
    }
}
