//
//  SD+General.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/5/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension SettingsData {
    static var generalSection: SettingsSection = {
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
                        indicatorStyle: .forwards,
                        destination: generalPage,
                        action: nil
                    )
                )
            ]
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
                                    title: "Swipe To Navigate",
                                    storage: \.$swipeToNavigate
                                )
                            )
                        ],
                        description: .constant(string: "Swipe left and right to change tabs.")
                    ),
                    .init(
                        rows: [
                            .init(
                                configuration: .button(
                                    title: "Reset All Settings",
                                    tintColor: nil,
                                    rightIconName: "arrow.clockwise"
                                ) {
                                    SettingsData.resetAllSettings?()
                                }
                            )
                        ]
                    )
                ]
            )
        )
    }()
}
