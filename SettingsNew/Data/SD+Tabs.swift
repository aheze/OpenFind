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
                        destination: cameraPage
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

    static var cameraPage: SettingsPage = {
        .init(
            title: "Camera",
            configuration: .sections(
                sections: [
                    .init(
                        header: "Frequency",
                        rows: [
                            .init(
                                configuration:
                                .picker(
                                    title: "Scan Every...",
                                    choices: [
                                        SettingsRow.PickerChoice(title: "Continuous", storageValue: Settings.Values.ScanningFrequencyLevel.continuous.rawValue),
                                        SettingsRow.PickerChoice(title: "0.5s", storageValue: Settings.Values.ScanningFrequencyLevel.halfSecond.rawValue),
                                        SettingsRow.PickerChoice(title: "1s", storageValue: Settings.Values.ScanningFrequencyLevel.oneSecond.rawValue),
                                        SettingsRow.PickerChoice(title: "2s", storageValue: Settings.Values.ScanningFrequencyLevel.twoSeconds.rawValue),
                                        SettingsRow.PickerChoice(title: "3s", storageValue: Settings.Values.ScanningFrequencyLevel.threeSeconds.rawValue)
                                    ],
                                    storage: \RealmModel.$cameraScanningFrequency
                                )
                            )
                        ],
                        description: .constant(string: "Control how often to scan the live preview.")
                    ),
                    .init(
                        header: "Conserving",
                        rows: [
                            .init(
                                configuration:
                                .picker(
                                    title: "Pause Scanning After...",
                                    choices: [
                                        SettingsRow.PickerChoice(title: "Never", storageValue: Settings.Values.ScanningDurationUntilPauseLevel.never.rawValue),
                                        SettingsRow.PickerChoice(title: "10s", storageValue: Settings.Values.ScanningDurationUntilPauseLevel.tenSeconds.rawValue),
                                        SettingsRow.PickerChoice(title: "30s", storageValue: Settings.Values.ScanningDurationUntilPauseLevel.thirtySeconds.rawValue),
                                        SettingsRow.PickerChoice(title: "1m", storageValue: Settings.Values.ScanningDurationUntilPauseLevel.sixtySeconds.rawValue)
                                    ],
                                    storage: \RealmModel.$cameraScanningDurationUntilPause
                                )
                            )
                        ],
                        description: .constant(string: "Pause scanning after a certain amount of time to conserve CPU usage.")
                    )
                ]
            )
        )
    }()
}
