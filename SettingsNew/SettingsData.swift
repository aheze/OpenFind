//
//  SettingsData.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

extension SettingsModel {
    static func data(model: SettingsViewModel) -> [SettingsSection] {
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
                            destination: generalPage(model: model)
                        )
                    )
                ]
            )
        ]
    }

    static func generalPage(model: SettingsViewModel) -> Page {
        .init(
            title: "General",
            configuration: .sections(
                sections: [
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
    }
}
