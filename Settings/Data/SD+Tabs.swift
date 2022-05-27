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
                        indicatorStyle: .forwards,
                        destination: photosPage,
                        action: nil
                    )
                ),
                .init(
                    configuration: .link(
                        title: "Camera",
                        leftIcon: .template(
                            iconName: "camera.fill",
                            backgroundColor: UIColor(hex: 0x007EEF)
                        ),
                        indicatorStyle: .forwards,
                        destination: cameraPage,
                        action: nil
                    )
                ),
                .init(
                    configuration: .link(
                        title: "Lists",
                        leftIcon: .template(
                            iconName: "rectangle.on.rectangle",
                            backgroundColor: UIColor(hex: 0xEAA800)
                        ),
                        indicatorStyle: .forwards,
                        destination: listsPage,
                        action: nil
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
                            .init(configuration: .custom(title: "Gallery Grid Size", identifier: .photosGridSize))
                        ],
                        description: .constant(string: "Configure the size of the grid in the Photos tab.")
                    ),
                    .init(
                        header: "Results",
                        rows: [
                            .init(
                                configuration: .picker(
                                    title: "Insert New Results",
                                    choices: [
                                        SettingsRow.PickerChoice(
                                            title: Settings.Values.PhotosResultsInsertNewMode.top.getTitle(),
                                            storageValue: Settings.Values.PhotosResultsInsertNewMode.top.rawValue
                                        ),
                                        SettingsRow.PickerChoice(
                                            title: Settings.Values.PhotosResultsInsertNewMode.bottom.getTitle(),
                                            storageValue: Settings.Values.PhotosResultsInsertNewMode.bottom.rawValue
                                        )
                                    ],
                                    storage: \RealmModel.$photosResultsInsertNewMode
                                )
                            )
                        ],
                        description: .dynamic(identifier: .photosResultsInsertNewMode)
                    ),
                    .init(
                        rows: [
                            .init(
                                configuration: .toggle(
                                    title: "Render Highlights",
                                    storage: \RealmModel.$photosRenderResultsHighlights
                                )
                            )
                        ],
                        description: .constant(string: "Render highlights in the results text excerpt. May have a performance impact on some devices.")
                    ),
                    .init(
                        rows: [
                            .init(
                                configuration: .link(
                                    title: "Advanced",
                                    leftIcon: nil,
                                    indicatorStyle: .forwards,
                                    destination: photosAdvancedPage,
                                    action: nil
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
                                ) {
                                    SettingsData.deleteAllScannedData?()
                                }
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
                        header: "Haptic Feedback",
                        rows: [
                            .init(
                                configuration: .custom(
                                    title: "Haptic Feedback",
                                    identifier: .cameraHapticFeedbackLevel
                                )
                            )
                        ],
                        description: .constant(string: "Generate haptic feedback when new results are found in the live preview.")
                    ),
                    .init(
                        header: "Frequency",
                        rows: [
                            .init(
                                configuration: .picker(
                                    title: "Scan Every",
                                    choices: [
                                        SettingsRow.PickerChoice(
                                            title: Settings.Values.ScanningFrequencyLevel.continuous.getTitle(),
                                            storageValue: Settings.Values.ScanningFrequencyLevel.continuous.rawValue
                                        ),
                                        SettingsRow.PickerChoice(
                                            title: Settings.Values.ScanningFrequencyLevel.tenthSecond.getTitle(),
                                            storageValue: Settings.Values.ScanningFrequencyLevel.tenthSecond.rawValue
                                        ),
                                        SettingsRow.PickerChoice(
                                            title: Settings.Values.ScanningFrequencyLevel.quarterSecond.getTitle(),
                                            storageValue: Settings.Values.ScanningFrequencyLevel.quarterSecond.rawValue
                                        ),
                                        SettingsRow.PickerChoice(
                                            title: Settings.Values.ScanningFrequencyLevel.halfSecond.getTitle(),
                                            storageValue: Settings.Values.ScanningFrequencyLevel.halfSecond.rawValue
                                        ),
                                        SettingsRow.PickerChoice(
                                            title: Settings.Values.ScanningFrequencyLevel.threeQuartersSecond.getTitle(),
                                            storageValue: Settings.Values.ScanningFrequencyLevel.threeQuartersSecond.rawValue
                                        ),
                                        SettingsRow.PickerChoice(
                                            title: Settings.Values.ScanningFrequencyLevel.oneSecond.getTitle(),
                                            storageValue: Settings.Values.ScanningFrequencyLevel.oneSecond.rawValue
                                        )
                                    ],
                                    storage: \RealmModel.$cameraScanningFrequency
                                )
                            )
                        ],
                        description: .dynamic(identifier: .scanningFrequency)
                    ),
                    .init(
                        header: "Conserving",
                        rows: [
                            .init(
                                configuration: .picker(
                                    title: "Pause Scanning After",
                                    choices: [
                                        SettingsRow.PickerChoice(
                                            title: Settings.Values.ScanningDurationUntilPauseLevel.never.getTitle(),
                                            storageValue: Settings.Values.ScanningDurationUntilPauseLevel.never.rawValue
                                        ),
                                        SettingsRow.PickerChoice(
                                            title: Settings.Values.ScanningDurationUntilPauseLevel.fiveSeconds.getTitle(),
                                            storageValue: Settings.Values.ScanningDurationUntilPauseLevel.fiveSeconds.rawValue
                                        ),
                                        SettingsRow.PickerChoice(
                                            title: Settings.Values.ScanningDurationUntilPauseLevel.tenSeconds.getTitle(),
                                            storageValue: Settings.Values.ScanningDurationUntilPauseLevel.tenSeconds.rawValue
                                        ),
                                        SettingsRow.PickerChoice(
                                            title: Settings.Values.ScanningDurationUntilPauseLevel.thirtySeconds.getTitle(),
                                            storageValue: Settings.Values.ScanningDurationUntilPauseLevel.thirtySeconds.rawValue
                                        ),
                                        SettingsRow.PickerChoice(
                                            title: Settings.Values.ScanningDurationUntilPauseLevel.sixtySeconds.getTitle(),
                                            storageValue: Settings.Values.ScanningDurationUntilPauseLevel.sixtySeconds.rawValue
                                        )
                                    ],
                                    storage: \RealmModel.$cameraScanningDurationUntilPause
                                )
                            )
                        ],
                        description: .dynamic(identifier: .pauseScanningAfter)
                    ),
                    .init(
                        header: "Video Stabilization",
                        rows: [
                            .init(
                                configuration: .picker(
                                    title: "Stabilization",
                                    choices: [
                                        SettingsRow.PickerChoice(
                                            title: Settings.Values.StabilizationMode.off.getTitle(),
                                            storageValue: Settings.Values.StabilizationMode.off.rawValue
                                        ),
                                        SettingsRow.PickerChoice(
                                            title: Settings.Values.StabilizationMode.standard.getTitle(),
                                            storageValue: Settings.Values.StabilizationMode.standard.rawValue
                                        ),
                                        SettingsRow.PickerChoice(
                                            title: Settings.Values.StabilizationMode.cinematic.getTitle(),
                                            storageValue: Settings.Values.StabilizationMode.cinematic.rawValue
                                        ),
                                        SettingsRow.PickerChoice(
                                            title: Settings.Values.StabilizationMode.cinematicExtended.getTitle(),
                                            storageValue: Settings.Values.StabilizationMode.cinematicExtended.rawValue
                                        ),
                                        SettingsRow.PickerChoice(
                                            title: Settings.Values.StabilizationMode.auto.getTitle(),
                                            storageValue: Settings.Values.StabilizationMode.auto.rawValue
                                        )
                                    ],
                                    storage: \RealmModel.$cameraStabilizationMode
                                )
                            )
                        ],
                        description: .dynamic(identifier: .cameraStabilizationMode)
                    )
                ]
            )
        )
    }()

    static var listsPage: SettingsPage = {
        .init(
            title: "Lists",
            configuration: .sections(
                sections: [
                    .init(
                        rows: [
                            .init(
                                configuration: .picker(
                                    title: "Sort By",
                                    choices: [
                                        SettingsRow.PickerChoice(title: "Newest First", storageValue: Settings.Values.ListsSortByLevel.newestFirst.rawValue),
                                        SettingsRow.PickerChoice(title: "Oldest First", storageValue: Settings.Values.ListsSortByLevel.oldestFirst.rawValue),
                                        SettingsRow.PickerChoice(title: "Title", storageValue: Settings.Values.ListsSortByLevel.title.rawValue)
                                    ],
                                    storage: \RealmModel.$listsSortBy
                                )
                            )
                        ]
                    ),
                    .init(
                        rows: [
                            .init(
                                configuration: .button(
                                    title: "Export All Lists",
                                    tintColor: Colors.accent,
                                    rightIconName: "square.and.arrow.up"
                                ) {
                                    exportAllLists?()
                                }
                            )
                        ]
                    )
                ]
            )
        )
    }()
}
