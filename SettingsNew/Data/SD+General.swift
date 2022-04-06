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
                        showRightIndicator: true,
                        destination: generalPage
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
                        header: "Haptic Feedback",
                        rows: [
                            .init(
                                configuration: .custom(identifier: .hapticFeedbackLevel)
                            )
                        ]
                    ),
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
                    )
                ]
            )
        )
    }()
}
