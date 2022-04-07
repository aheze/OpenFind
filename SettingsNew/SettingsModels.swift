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
    var bottomViewIdentifier: Settings.ViewIdentifier? /// description at bottom, like `Version 1.3.0 - See What's New`
    var addTopPadding = true

    /// pass in information to a page
    enum Configuration {
        case sections(sections: [SettingsSection])
        case custom(identifier: Settings.ViewIdentifier)
        case picker(
            title: String,
            choices: [SettingsRow.PickerChoice],
            storage: KeyPath<RealmModel, Binding<String>>
        )
        case license(
            license: License
        )
        case dynamicPicker(
            title: String,
            identifier: Settings.DynamicPickerIdentifier
        )
    }
}

struct SettingsSection: Identifiable {
    let id = UUID()
    var header: String? /// shown at top
    var rows = [SettingsRow]()
    var customViewIdentifier: Settings.ViewIdentifier? /// show above the rows
    var description: Description? /// shown at bottom of rows

    enum Description {
        case constant(string: String)
        case dynamic(identifier: Settings.StringIdentifier)
    }
}

struct SettingsRow: Identifiable {
    let id = UUID()
    var configuration: Configuration
    enum Configuration {
        case link(
            title: String,
            leftIcon: Icon?,
            indicatorStyle: IndicatorStyle?,
            destination: SettingsPage?,
            action: (() -> Void)? /// called when row tapped
        )
        case toggle(title: String, storage: KeyPath<RealmModel, Binding<Bool>>)
        case button(title: String, tintColor: UIColor?, rightIconName: String?, action: (() -> Void)?)

        /// if `numberOfSteps` is nil, smooth slider
        case slider(
            numberOfSteps: Int?,
            minValue: Double,
            maxValue: Double,
            minSymbol: Symbol,
            maxSymbol: Symbol,
            saveAsInt: Bool, /// precision
            storage: KeyPath<RealmModel, Binding<Double>>
        )

        /// open in new page
        case picker(
            title: String,
            choices: [PickerChoice],
            storage: KeyPath<RealmModel, Binding<String>>
        )
        
        /// open in new page
        case dynamicPicker(
            title: String,
            identifier: Settings.DynamicPickerIdentifier
        )
        
        case custom(identifier: Settings.ViewIdentifier)
    }

    enum Icon {
        case template(iconName: String, backgroundColor: UIColor)
        case image(imageName: String, inset: CGFloat, backgroundColor: UIColor)
        case custom(identifier: Settings.ViewIdentifier)
    }

    enum Symbol {
        case system(name: String, weight: UIFont.Weight)
        case text(string: String) /// text
    }

    enum IndicatorStyle {
        case forwards
        case modal
    }

    struct PickerChoice: Identifiable {
        let id = UUID()
        var title: String
        var storageValue: String
    }
}
