//
//  SettingsData.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

extension SettingsViewModel {
    static var mainPage: SettingsPage = .init(
        title: "Main Settings",
        configuration: .sections(sections: mainSections),
        bottomViewIdentifier: nil
    )

    static var mainSections: [SettingsSection] = {
        [
            /// general section
            .init(
                rows: [
                    .init(
                        configuration: .link(
                            title: "General",
                            leftIcon: .template(
                                iconName: "gear",
                                backgroundColor: UIColor(hex: 0x565656)
                            ),
                            showRightIndicator: true,
                            destination: generalPage
                        )
                    )
                ]
            ),

            /// finding and highlights (second section)
            .init(
                rows: [
                    .init(
                        configuration: .link(
                            title: "Finding",
                            leftIcon: .template(
                                iconName: "magnifyingglass",
                                backgroundColor: UIColor(hex: 0x008BEF)
                            ),
                            showRightIndicator: true,
                            destination: findingPage
                        )
                    )
                ]
            )
        ]
    }()

    static var findingPage: SettingsPage = {
        .init(
            title: "Finding",
            configuration: .sections(
                sections: [
                    .init(
                        header: "Options",
                        rows: [
                            .init(configuration: .toggle(title: "Keep Whitespace", storage: \SettingsViewModel.$keepWhitespace)),
                            .init(configuration: .toggle(title: "Match Accents", storage: \SettingsViewModel.$matchAccents)),
                            .init(configuration: .toggle(title: "Match Case", storage: \SettingsViewModel.$matchCase))
                        ]
                    ),
                    .init(
                        rows: [
                            .init(configuration: .toggle(title: "Filter Lists", storage: \SettingsViewModel.$filterLists))
                        ],
                        description: .constant(string: "Filter lists when typing in the search bar")
                    )
                ]
            )
        )
    }()

    static var subPage: SettingsPage = {
        .init(
            title: "SubPage",
            configuration: .sections(
                sections: [
                    .init(
                        rows: [
                            .init(
                                configuration: .button(title: "Last button", action: {})
                            )
                        ]
                    )
                ]
            )
        )
    }()

    static var generalPage: SettingsPage = {
        .init(
            title: "General",
            configuration: .sections(
                sections: [
                    .init(
                        rows: [
                            .init(
                                configuration: .custom(identifier: SettingsIdentifiers.hapticFeedbackLevel)
                            )
                        ]
                    ),
                    .init(
                        rows: [
                            .init(
                                configuration: .toggle(
                                    title: "Swipe To Navigate",
                                    storage: \SettingsViewModel.$swipeToNavigate
                                )
                            )
                        ],
                        description: .constant(string: "Swipe left and right to change tabs.")
                    )
                ]
            )
        )
    }()
}
