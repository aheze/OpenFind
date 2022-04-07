//
//  SettingsDeepLink.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/6/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct SettingsDeepLink: View {
    @ObservedObject var model: SettingsViewModel
    @ObservedObject var realmModel: RealmModel

    var title: String
    var rows: [SettingsRow]

    var body: some View {
        SettingsRowButton {
            model.showRows?(rows)
        } content: {
            if case .link(
                title: let title,
                leftIcon: _,
                indicatorStyle: let indicatorStyle,
                destination: _,
                action: _
            ) = rows.first?.configuration {
                HStack(spacing: SettingsConstants.rowIconTitleSpacing) {
                    Text(getDestinationTitle())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(SettingsConstants.rowVerticalInsetsFromText)

                    if let indicatorStyle = indicatorStyle {
                        switch indicatorStyle {
                        case .forwards:
                            Image(systemName: "chevron.forward")
                                .foregroundColor(UIColor.secondaryLabel.color)
                        case .modal:
                            Image(systemName: "arrow.up.forward")
                                .foregroundColor(UIColor.secondaryLabel.color)
                        }
                    }
                }
                .padding(SettingsConstants.rowHorizontalInsets)
            }
        }
    }

    func getDestinationTitle() -> String {
        guard let row = rows.last else { return "" }
        switch row.configuration {
        case .link(title: let title, leftIcon: let leftIcon, indicatorStyle: let indicatorStyle, destination: let destination, action: let action):
            return title
        case .deepLink(title: let title, rows: let rows):
            return title
        case .toggle(title: let title, storage: let storage):
            return title
        case .button(title: let title, tintColor: let tintColor, rightIconName: let rightIconName, action: let action):
            return title
        case .slider(numberOfSteps: let numberOfSteps, minValue: let minValue, maxValue: let maxValue, minSymbol: let minSymbol, maxSymbol: let maxSymbol, saveAsInt: let saveAsInt, storage: let storage):
            return ""
        case .picker(title: let title, choices: let choices, storage: let storage):
            return title
        case .dynamicPicker(title: let title, identifier: let identifier):
            return title
        case .custom(identifier: let identifier):
            return ""
        }
    }
}
