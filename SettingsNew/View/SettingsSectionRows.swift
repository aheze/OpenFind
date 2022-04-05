//
//  SettingsSectionRows.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct SettingsSectionRows: View {
    @ObservedObject var model: SettingsViewModel
    let section: SettingsSection
    var body: some View {
        /// encompass section rows
        VStack(spacing: 0) {
            ForEach(Array(zip(section.rows.indices, section.rows)), id: \.1.id) { index, row in

                let leftDividerPadding = SettingsConstants.rowInsets.leading

                switch row.configuration {
                case .link(
                    title: let title,
                    leftIcon: let leftIcon,
                    showRightIndicator: let showRightIndicator,
                    destination: let destination
                ):
                    SettingsLink(
                        model: model,
                        title: title,
                        leftIcon: leftIcon,
                        showRightIndicator: showRightIndicator,
                        destination: destination
                    )
                case .toggle(
                    title: let title,
                    storage: let storage
                ):
                    SettingsToggle(
                        model: model,
                        title: title,
                        storage: storage
                    )
                case .button(
                    title: let title,
                    action: let action
                ):
                    EmptyView()
                case .slider(
                    title: let title,
                    numberOfSteps: let numberOfSteps,
                    minValue: let minValue,
                    maxValue: let maxValue,
                    minSymbol: let minSymbol,
                    maxSymbol: let maxSymbol,
                    numberOfDecimalPlaces: let numberOfDecimalPlaces,
                    storageKey: let storageKey
                ):
                    EmptyView()
                case .picker(
                    choices: let choices,
                    storage: let storage
                ):
                    EmptyView()
                case .custom(
                    identifier: let identifier
                ):
                    SettingsCustomView(identifier: identifier)
                }

                if index < section.rows.count - 1 {
                    Rectangle()
                        .fill(SettingsConstants.dividerColor.color)
                        .frame(height: SettingsConstants.dividerHeight)
                        .padding(.leading, leftDividerPadding)
                }
            }
        }
        .background(UIColor.systemBackground.color)
        .cornerRadius(SettingsConstants.sectionCornerRadius)
    }
}
