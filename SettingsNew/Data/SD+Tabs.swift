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
                                configuration: .button(title: "Scanning Options", tintColor: nil, rightIconName: "arrow.up.forward") {
                                    showScanningOptions?()
                                }
                            )
                        ]
                    ),
                    .init(
                        header: "Gallery Grid Size",
                        rows: [
                            .init(configuration: .custom(identifier: .photosGridSize))
                        ],
                        description: .constant(string: "Configure the size of the grid in the Photos tab.")
                    ),
                    .init(
                        rows: [
                            .init(
                                configuration: .link(
                                    title: "Advanced",
                                    leftIcon: nil,
                                    showRightIndicator: true,
                                    destination: photosAdvancedPage
                                )
                            )
                        ]
                    )
                ]
            )
        )
    }()

    static var photosAdvancedPage: SettingsPage = {
        .init(
            title: "Advanced",
            configuration: .sections(
                sections: [
                    .init(
                        rows: [
                            .init(
                                configuration: .button(
                                    title: "Delete All Scanned Data",
                                    tintColor: UIColor.systemRed,
                                    rightIconName: "trash"
                                ) {}
                            )
                        ],
                        description: .constant(string: "All scanned data will be deleted. You will need to rescan photos to find in them.")
                    )
                ]
            )
        )
    }()
}
