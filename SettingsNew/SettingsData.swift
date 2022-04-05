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
                                iconName: "gear",
                                backgroundColor: UIColor(hex: 0x565656)
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
                        rows: [
                            .init(
                                configuration: .picker(
                                    choices: [
                                        .init(title: "", storageValue: "")
                                    ],
                                    storage: \SettingsViewModel.$hapticFeedbackLevel
                                )
                            ),
                            .init(
                                configuration: .link(
                                    title: "Go to sub page",
                                    leftIcon: nil,
                                    showRightIndicator: true,
                                    destination: subPage
                                )
                            )
                        ]
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
                                configuration: .button(title: "Last button", action: {
                                    
                                })
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
                                configuration: .toggle(
                                    title: "Haptic Feedback",
                                    storage: \SettingsViewModel.$swipeToNavigate
                                )
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
