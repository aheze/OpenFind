//
//  SettingsPicker.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct SettingsPicker: View {
    @ObservedObject var model: SettingsViewModel
    @ObservedObject var realmModel: RealmModel
    var title: String
    var choices: [SettingsRow.PickerChoice]
    var storage: KeyPath<RealmModel, Binding<String>>

    var body: some View {
        SettingsRowButton {
            let pickerPage = SettingsPage.getPickerPage(title: title, choices: choices, storage: storage)
            model.show?(pickerPage)
        } content: {
            HStack(spacing: SettingsConstants.rowIconTitleSpacing) {
                Text(title)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(SettingsConstants.rowVerticalInsetsFromText)

                Text(getSelectedChoiceTitle())
                    .foregroundColor(UIColor.secondaryLabel.color)

                Image(systemName: "chevron.forward")
                    .foregroundColor(UIColor.secondaryLabel.color)
            }
            .padding(SettingsConstants.rowHorizontalInsets)
        }
        .disabled(!model.touchesEnabled) /// stop buttons from sticking down even after scroll
    }

    func getSelectedChoiceTitle() -> String {
        let selectedValue = realmModel[keyPath: storage].wrappedValue
        if let selectedPickerChoice = choices.first(where: { $0.storageValue == selectedValue }) {
            return selectedPickerChoice.title
        }
        return selectedValue
    }
}

struct SettingsPickerPage: View {
    @ObservedObject var model: SettingsViewModel
    @ObservedObject var realmModel: RealmModel
    var title: String
    var choices: [SettingsRow.PickerChoice]
    var storage: KeyPath<RealmModel, Binding<String>>

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(zip(choices.indices, choices)), id: \.1.id) { index, choice in

                SettingsRowButton {
                    realmModel[keyPath: storage].wrappedValue = choice.storageValue
                } content: {
                    HStack {
                        Text(choice.title)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(SettingsConstants.rowVerticalInsetsFromText)

                        if choiceIsSelected(choice: choice) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accent)
                        }
                    }
                    .padding(SettingsConstants.rowHorizontalInsets)
                }
                .disabled(!model.touchesEnabled) /// stop buttons from sticking down even after scroll

                if index < choices.count - 1 {
                    SettingsRowDivider()
                }
            }
        }
        .background(UIColor.systemBackground.color)
        .cornerRadius(SettingsConstants.sectionCornerRadius)
    }

    func choiceIsSelected(choice: SettingsRow.PickerChoice) -> Bool {
        return realmModel[keyPath: storage].wrappedValue == choice.storageValue
    }
}

extension SettingsPage {
    static func getPickerPage(
        title: String,
        choices: [SettingsRow.PickerChoice],
        storage: KeyPath<RealmModel, Binding<String>>
    ) -> SettingsPage {
        let page = SettingsPage(
            title: title,
            explanation: nil,
            configuration: .picker(
                title: title,
                choices: choices,
                storage: storage
            ),
            bottomViewIdentifier: nil
        )
        return page
    }
}
