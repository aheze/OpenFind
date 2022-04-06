//
//  SD+Tabs.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/5/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

extension SettingsData {
    static var tabsSection: SettingsSection = {
        .init(
            rows: [
                .init(
                    configuration: .link(
                        title: "Photos",
                        leftIcon: .template(
                            iconName: "photo",
                            backgroundColor: UIColor(hex: 0x00AD30)
                        ),
                        showRightIndicator: true,
                        destination: photosPage
                    )
                ),
                .init(
                    configuration: .link(
                        title: "Camera",
                        leftIcon: .template(
                            iconName: "camera.fill",
                            backgroundColor: UIColor(hex: 0x007EEF)
                        ),
                        showRightIndicator: true,
                        destination: highlightsPage
                    )
                ),
                .init(
                    configuration: .link(
                        title: "Lists",
                        leftIcon: .template(
                            iconName: "rectangle.on.rectangle",
                            backgroundColor: UIColor(hex: 0xEAA800)
                        ),
                        showRightIndicator: true,
                        destination: highlightsPage
                    )
                )
            ]
        )
    }()
    
    static var photosPage: SettingsPage = {
        .init(
            title: "Photos",
            configuration: .sections(
                sections: [
                    .init(
                        rows: [
                            .init(
                                configuration: .button(title: "Scanning Options", rightIconName: "arrow.up.forward") {
                                    
                                }
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
