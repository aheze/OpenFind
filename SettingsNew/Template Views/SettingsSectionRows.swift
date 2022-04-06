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
    @ObservedObject var realmModel: RealmModel
    let section: SettingsSection

    var body: some View {
        /// encompass section rows
        VStack(spacing: 0) {
            ForEach(Array(zip(section.rows.indices, section.rows)), id: \.1.id) { index, row in

                switch row.configuration {
                case .link(
                    title: let title,
                    leftIcon: let leftIcon,
                    indicatorStyle: let indicatorStyle,
                    destination: let destination,
                    action: let action
                ):
                    SettingsLink(
                        model: model,
                        realmModel: realmModel,
                        title: title,
                        leftIcon: leftIcon,
                        indicatorStyle: indicatorStyle,
                        destination: destination,
                        action: action
                    )
                case .toggle(
                    title: let title,
                    storage: let storage
                ):
                    SettingsToggle(
                        model: model,
                        realmModel: realmModel,
                        title: title,
                        storage: storage
                    )
                case .button(
                    title: let title,
                    tintColor: let tintColor,
                    rightIconName: let rightIconName,
                    action: let action
                ):
                    SettingsButton(
                        model: model,
                        realmModel: realmModel,
                        title: title,
                        tintColor: tintColor,
                        rightIconName: rightIconName,
                        action: action
                    )
                case .slider(
                    numberOfSteps: let numberOfSteps,
                    minValue: let minValue,
                    maxValue: let maxValue,
                    minSymbol: let minSymbol,
                    maxSymbol: let maxSymbol,
                    saveAsInt: let saveAsInt,
                    storage: let storage
                ):
                    SettingsSlider(
                        model: model,
                        realmModel: realmModel,
                        numberOfSteps: numberOfSteps,
                        minValue: minValue,
                        maxValue: maxValue,
                        minSymbol: minSymbol,
                        maxSymbol: maxSymbol,
                        saveAsInt: saveAsInt,
                        storage: storage
                    )
                case .picker(
                    title: let title,
                    choices: let choices,
                    storage: let storage
                ):
                    SettingsPicker(
                        model: model,
                        realmModel: realmModel,
                        title: title,
                        choices: choices,
                        storage: storage
                    )
                case .dynamicPicker(
                    title: let title,
                    valueToChoiceTitle: let valueToChoiceTitle,
                    identifier: let identifier,
                    storage: let storage
                ):
                    SettingsDynamicPicker(
                        model: model,
                        realmModel: realmModel,
                        title: title,
                        valueToChoiceTitle: valueToChoiceTitle,
                        identifier: identifier,
                        storage: storage
                    )
                case .custom(
                    identifier: let identifier
                ):
                    SettingsCustomView(model: model, realmModel: realmModel, identifier: identifier)
                }

                if index < section.rows.count - 1 {
                    SettingsRowDivider(leftDividerPadding: getLeftDividerPadding(for: row))
                }
            }
        }
        .background(UIColor.systemBackground.color)
        .cornerRadius(SettingsConstants.sectionCornerRadius)
    }
    
    func getLeftDividerPadding(for row: SettingsRow) -> CGFloat {
        let leftDividerPadding = SettingsConstants.rowHorizontalInsets.leading
        var additionalPadding = CGFloat(0)
        switch row.configuration {
        case .link(title: _, leftIcon: let leftIcon, indicatorStyle: _, destination: _, action: _):
            if leftIcon != nil {
                additionalPadding = SettingsConstants.iconSize.width + SettingsConstants.rowIconTitleSpacing
            }
        case .toggle:
            break
        case .button:
            break
        case .slider:
            break
        case .picker:
            break
        case .dynamicPicker:
            break
        case .custom:
            break
        }
        
        return leftDividerPadding + additionalPadding
    }
}
