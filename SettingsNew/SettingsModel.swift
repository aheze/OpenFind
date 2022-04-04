//
//  SettingsModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct SettingsModel {
    var sections = [SettingsSection]()
    var pagePaths: [Page]? /// all possible paths in the tree, including incomplete/unfinished paths (paths that stop before hitting the last option)
}

struct Page {
    var title: String /// shown in navigation bar
    var explanation: String? /// shown at top of page, under navigation bar
    var configuration: Configuration
    var bottomViewIdentifier: AnyHashable? /// description at bottom, like `Version 1.3.0 - See What's New`

    enum Configuration {
        case sections(sections: [SettingsSection])
        case custom(identifier: AnyHashable)
    }
}

struct SettingsSection {
    var header: String? /// shown at top
    var rows = [SettingsRow]()
    var description: Description? /// shown at bottom of rows

    enum Description {
        case constant(string: String)
        case dynamic(getString: (() -> String))
    }
}

struct SettingsRow {
    var configuration: Configuration
    enum Configuration {
        case link(title: String, leftIcon: Icon?, showRightIndicator: Bool, destination: Page?)
        case toggle(title: String, storage: KeyPath<SettingsViewModel, Binding<Bool>>)
        case button(title: String, action: (() -> Void)?)

        /// if `numberOfSteps` is nil, smooth slider
        case slider(
            title: String,
            numberOfSteps: Int?,
            minValue: Double,
            maxValue: Double,
            minSymbol: Symbol,
            maxSymbol: Symbol,
            numberOfDecimalPlaces: Int,
            storageKey: String
        )

        /// open in new page
        case picker(choices: [PickerChoice], storage: KeyPath<SettingsViewModel, Binding<String>>)
        case custom(identifier: AnyHashable)
    }

    enum Icon {
        case template(iconName: String, backgroundColor: UIColor)
        case custom(identifier: AnyHashable)
    }

    enum Symbol {
        case system(name: String)
        case text(string: String) /// text
    }

    struct PickerChoice {
        var title: String
        var storageValue: String
    }
}
