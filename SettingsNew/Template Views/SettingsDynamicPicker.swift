//
//  SettingsDynamicPicker.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/6/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import SwiftUI

struct SettingsDynamicPicker: View {
    @ObservedObject var model: SettingsViewModel
    @ObservedObject var realmModel: RealmModel
    var title: String
    var valueToChoiceTitle: ((String) -> String)
    var identifier: Settings.ViewIdentifier
    var storage: KeyPath<RealmModel, Binding<String>>

    var body: some View {
        SettingsRowButton {
            let pickerPage = SettingsPage.getDynamicPickerPage(title: title, identifier: identifier, storage: storage)
            model.show?(pickerPage)
        } content: {
            HStack(spacing: SettingsConstants.rowIconTitleSpacing) {
                Text(title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(SettingsConstants.rowVerticalInsetsFromText)

                Text(getSelectedChoiceTitle())
                    .foregroundColor(UIColor.secondaryLabel.color)

                Image(systemName: "chevron.forward")
                    .foregroundColor(UIColor.secondaryLabel.color)
            }
            .padding(SettingsConstants.rowHorizontalInsets)
        }
    }

    func getSelectedChoiceTitle() -> String {
        let selectedValue = realmModel[keyPath: storage].wrappedValue
        let title = valueToChoiceTitle(selectedValue)
        return title
    }
}

extension SettingsPage {
    static func getDynamicPickerPage(
        title: String,
        identifier: Settings.ViewIdentifier,
        storage: KeyPath<RealmModel, Binding<String>>
    ) -> SettingsPage {
        let page = SettingsPage(
            title: title,
            explanation: nil,
            configuration: .custom(
                identifier: identifier
            ),
            bottomViewIdentifier: nil
        )
        return page
    }
}
