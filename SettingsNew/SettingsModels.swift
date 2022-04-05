//
//  SettingsModels.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI


struct SettingsPage {
    var title: String /// shown in navigation bar
    var explanation: String? /// shown at top of page, under navigation bar
    var configuration: Configuration
    var bottomViewIdentifier: Settings.Identifier? /// description at bottom, like `Version 1.3.0 - See What's New`

    enum Configuration {
        case sections(sections: [SettingsSection])
        case custom(identifier: Settings.Identifier)
    }
}

struct SettingsSection: Identifiable {
    let id = UUID()
    var header: String? /// shown at top
    var rows = [SettingsRow]()
    var description: Description? /// shown at bottom of rows

    enum Description {
        case constant(string: String)
        case dynamic(getString: () -> String)
    }
}

struct SettingsRow: Identifiable {
    let id = UUID()
    var configuration: Configuration
    enum Configuration {
        case link(title: String, leftIcon: Icon?, showRightIndicator: Bool, destination: SettingsPage)
        case toggle(title: String, storage: KeyPath<SettingsViewModel, Binding<Bool>>)
        case button(title: String, action: (() -> Void)?)

        /// if `numberOfSteps` is nil, smooth slider
        case slider(
            numberOfSteps: Int?,
            minValue: Double,
            maxValue: Double,
            minSymbol: Symbol,
            maxSymbol: Symbol,
            saveAsInt: Bool, /// precision
            storage: KeyPath<SettingsViewModel, Binding<Double>>
        )

        /// open in new page
        case picker(choices: [PickerChoice], storage: KeyPath<SettingsViewModel, Binding<String>>)
        case custom(identifier: Settings.Identifier)
    }

    enum Icon {
        case template(iconName: String, backgroundColor: UIColor)
        case custom(identifier: Settings.Identifier)
    }

    enum Symbol {
        case system(name: String, weight: UIFont.Weight)
        case text(string: String) /// text
    }

    struct PickerChoice {
        var title: String
        var storageValue: String
    }
}
