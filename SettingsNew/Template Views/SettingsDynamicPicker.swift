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
        let values = getValues()

        VStack(spacing: 0) {
            /// encompass section rows
            VStack(spacing: 0) {
                ForEach(Array(zip(values.indices, values)), id: \.1.self) { index, value in
                    let softwareLimitationString = softwareLimitationString(value: value)

                    SettingsRowButton {
                        valuePressed(value: value)
                    } content: {
                        HStack {
                            Text(getTitle(value: value))
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(SettingsConstants.rowVerticalInsetsFromText)
                                .opacity(softwareLimitationString != nil ? 0.5 : 1)

                            if let softwareLimitationString = softwareLimitationString {
                                Text(softwareLimitationString)
                                    .capsuleTipStyle()
                            }

                            if valueIsSelected(value: value) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accent)
                            }
                        }
                        .padding(SettingsConstants.rowHorizontalInsets)
                    }
                    .disabled(softwareLimitationString != nil)

                    if index < values.count - 1 {
                        SettingsRowDivider()
                    }
                }
            }
            .background(UIColor.systemBackground.color)
            .cornerRadius(SettingsConstants.sectionCornerRadius)

            if let description = getDescription() {
                Text(description)
                    .settingsDescriptionStyle()
            }
        }
    }

    func valuePressed(value: String) {
        withAnimation {
            switch identifier {
            case .primaryRecognitionLanguage:
                realmModel.findingPrimaryRecognitionLanguage = value

                /// if primary and secondary are the same, set secondary to `.none`.
                if realmModel.findingPrimaryRecognitionLanguage == realmModel.findingSecondaryRecognitionLanguage {
                    realmModel.findingSecondaryRecognitionLanguage = Settings.Values.RecognitionLanguage.none.rawValue
                }
            case .secondaryRecognitionLanguage:
                realmModel.findingSecondaryRecognitionLanguage = value
            }
        }
    }

    func getTitle(value: String) -> String {
        switch identifier {
        case .primaryRecognitionLanguage, .secondaryRecognitionLanguage:
            if let selectedLanguage = Settings.Values.RecognitionLanguage(rawValue: value) {
                return selectedLanguage.getTitle()
            }
        }
        return ""
    }

    func valueIsSelected(value: String) -> Bool {
        if let selectedValue = getSelectedValue() {
            return selectedValue == value
        }
        return false
    }

    /// if return something, the value is not available and so disable the row.
    func softwareLimitationString(value: String) -> String? {
        switch identifier {
        case .primaryRecognitionLanguage, .secondaryRecognitionLanguage:
            if let selectedLanguage = Settings.Values.RecognitionLanguage(rawValue: value) {
                let versionNeeded = selectedLanguage.versionNeeded()
                let versionUpdateNeeded = selectedLanguage.versionNeeded() > deviceVersion()

                if versionUpdateNeeded {
                    return "iOS \(versionNeeded)"
                }
            }
        }
        return nil
    }

    func deviceVersion() -> Int {
        if #available(iOS 14, *) {
            return 14
        } else {
            return 13
        }
    }

    func getValues() -> [String] {
        switch identifier {
        case .primaryRecognitionLanguage:
            let languages = Settings.Values.RecognitionLanguage.allCases.filter { $0 != .none }
            let values = languages.map { $0.rawValue }
            return values
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

            let values = languages.map { $0.rawValue }
            return values
        }
    }

    func getSelectedValue() -> String? {
        switch identifier {
        case .primaryRecognitionLanguage:
            guard let selectedLanguage = Settings.Values.RecognitionLanguage(rawValue: realmModel.findingPrimaryRecognitionLanguage) else { break }
            return selectedLanguage.rawValue
        case .secondaryRecognitionLanguage:
            guard let selectedLanguage = Settings.Values.RecognitionLanguage(rawValue: realmModel.findingSecondaryRecognitionLanguage) else { break }
            return selectedLanguage.rawValue
        }
        return nil
    }

    /// footer description
    func getDescription() -> String? {
        switch identifier {
        case .primaryRecognitionLanguage:
            return "Due to its complexity, Chinese does not work in the Camera live preview."
        case .secondaryRecognitionLanguage:
            return nil
        }
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
