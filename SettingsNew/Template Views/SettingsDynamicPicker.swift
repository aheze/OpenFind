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
    var identifier: Settings.DynamicPickerIdentifier

    var body: some View {
        SettingsRowButton {
            let pickerPage = SettingsPage.getDynamicPickerPage(title: title, identifier: identifier)
            model.show?(pickerPage)
        } content: {
            HStack(spacing: SettingsConstants.rowIconTitleSpacing) {
                Text(title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(SettingsConstants.rowVerticalInsetsFromText)

                Text(getSelectedChoice().title)
                    .foregroundColor(UIColor.secondaryLabel.color)

                Image(systemName: "chevron.forward")
                    .foregroundColor(UIColor.secondaryLabel.color)
            }
            .padding(SettingsConstants.rowHorizontalInsets)
        }
    }

    func getSelectedChoice() -> SettingsRow.PickerChoice {
        switch identifier {
        case .primaryRecognitionLanguage:
            guard let selectedLanguage = Settings.Values.RecognitionLanguage(rawValue: realmModel.findingPrimaryRecognitionLanguage) else { break }
            let choice = SettingsRow.PickerChoice(title: selectedLanguage.getTitle(), storageValue: selectedLanguage.rawValue)
            return choice
        case .secondaryRecognitionLanguage:
            guard let selectedLanguage = Settings.Values.RecognitionLanguage(rawValue: realmModel.findingSecondaryRecognitionLanguage) else { break }
            let choice = SettingsRow.PickerChoice(title: selectedLanguage.getTitle(), storageValue: selectedLanguage.rawValue)
            return choice
        }
        return .init(title: "", storageValue: "")
    }
}

struct SettingsDynamicPickerPage: View {
    @ObservedObject var model: SettingsViewModel
    @ObservedObject var realmModel: RealmModel
    var title: String
    var identifier: Settings.DynamicPickerIdentifier

    var body: some View {
        let choices = getChoices()
        VStack(spacing: 0) {
            ForEach(Array(zip(choices.indices, choices)), id: \.1.id) { index, choice in

                SettingsRowButton {
                    choicePressed(choice: choice)
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

                if index < choices.count - 1 {
                    SettingsRowDivider()
                }
            }
        }
        .background(UIColor.systemBackground.color)
        .cornerRadius(SettingsConstants.sectionCornerRadius)
    }

    func choicePressed(choice: SettingsRow.PickerChoice) {
        switch identifier {
        case .primaryRecognitionLanguage:
            realmModel.findingPrimaryRecognitionLanguage = choice.storageValue
            
            
            /// if primary and secondary are the same, set secondary to `.none`.
            if realmModel.findingPrimaryRecognitionLanguage == realmModel.findingSecondaryRecognitionLanguage {
                realmModel.findingSecondaryRecognitionLanguage = Settings.Values.RecognitionLanguage.none.rawValue
            }
        case .secondaryRecognitionLanguage:
            realmModel.findingSecondaryRecognitionLanguage = choice.storageValue
        }
    }

    func getChoices() -> [SettingsRow.PickerChoice] {
        switch identifier {
        case .primaryRecognitionLanguage:
            let languages = Settings.Values.RecognitionLanguage.allCases.filter { $0 != .none }
            let choices = languages.map { SettingsRow.PickerChoice(title: $0.getTitle(), storageValue: $0.rawValue) }
            return choices
        case .secondaryRecognitionLanguage:
            let languages: [Settings.Values.RecognitionLanguage]
            let selectedPrimaryRecognitionLanguageString = realmModel.findingPrimaryRecognitionLanguage
            if let selectedPrimaryRecognitionLanguage = Settings.Values.RecognitionLanguage(rawValue: selectedPrimaryRecognitionLanguageString) {
                languages = Settings.Values.RecognitionLanguage.allCases.filter {
                    $0 != selectedPrimaryRecognitionLanguage
                    && !$0.requiresAccurateMode()
                }
            } else {
                languages = Settings.Values.RecognitionLanguage.allCases
            }

            let choices = languages.map { SettingsRow.PickerChoice(title: $0.getTitle(), storageValue: $0.rawValue) }
            return choices
        }
    }

    func getSelectedChoice() -> SettingsRow.PickerChoice {
        switch identifier {
        case .primaryRecognitionLanguage:
            guard let selectedLanguage = Settings.Values.RecognitionLanguage(rawValue: realmModel.findingPrimaryRecognitionLanguage) else { break }
            let choice = SettingsRow.PickerChoice(title: selectedLanguage.getTitle(), storageValue: selectedLanguage.rawValue)
            return choice
        case .secondaryRecognitionLanguage:
            guard let selectedLanguage = Settings.Values.RecognitionLanguage(rawValue: realmModel.findingSecondaryRecognitionLanguage) else { break }
            let choice = SettingsRow.PickerChoice(title: selectedLanguage.getTitle(), storageValue: selectedLanguage.rawValue)
            return choice
        }
        return .init(title: "", storageValue: "")
    }

    func choiceIsSelected(choice: SettingsRow.PickerChoice) -> Bool {
        return getSelectedChoice().storageValue == choice.storageValue
    }
}

extension SettingsPage {
    static func getDynamicPickerPage(
        title: String,
        identifier: Settings.DynamicPickerIdentifier
    ) -> SettingsPage {
        let page = SettingsPage(
            title: title,
            explanation: nil,
            configuration: .dynamicPicker(
                title: title,
                identifier: identifier
            ),
            bottomViewIdentifier: nil
        )
        return page
    }
}
