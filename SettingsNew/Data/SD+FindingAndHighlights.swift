//
//  SD+FindingAndHighlights.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/5/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension SettingsData {
    static var findingAndHighlightsSection: SettingsSection = {
        .init(
            rows: [
                .init(
                    configuration: .link(
                        title: "Finding",
                        leftIcon: .image(
                            imageName: "Find",
                            inset: 8,
                            backgroundColor: UIColor(hex: 0x008BEF)
                        ),
                        indicatorStyle: .forwards,
                        destination: findingPage,
                        action: nil
                    )
                ),
                .init(
                    configuration: .link(
                        title: "Highlights",
                        leftIcon: .custom(identifier: .highlightsIcon),
                        indicatorStyle: .forwards,
                        destination: highlightsPage,
                        action: nil
                    )
                )
            ]
        )
    }()

    static var findingPage: SettingsPage = {
        .init(
            title: "Finding",
            configuration: .sections(
                sections: [
                    .init(
                        header: "Recognition Languages",
                        rows: [
                            .init(
                                configuration: .dynamicPicker(
                                    title: "Primary",
                                    valueToChoiceTitle: { string in
                                        if let language = Settings.Values.RecognitionLanguage(rawValue: string) {
                                            return language.getTitle()
                                        }
                                        return string
                                    },
                                    identifier: .primaryRecognitionLanguage,
                                    storage: \.$findingPrimaryRecognitionLanguage
                                )
                            ),
                            .init(
                                configuration: .dynamicPicker(
                                    title: "Secondary",
                                    valueToChoiceTitle: { string in
                                        if let language = Settings.Values.RecognitionLanguage(rawValue: string) {
                                            return language.getTitle()
                                        }
                                        return string
                                    },
                                    identifier: .secondaryRecognitionLanguage,
                                    storage: \.$findingSecondaryRecognitionLanguage
                                )
                            )
                        ]
                    ),
                    .init(
                        header: "Options",
                        rows: [
                            .init(configuration: .toggle(title: "Keep Whitespace", storage: \.$findingKeepWhitespace)),
                            .init(configuration: .toggle(title: "Match Accents", storage: \.$findingMatchAccents)),
                            .init(configuration: .toggle(title: "Match Case", storage: \.$findingMatchCase))
                        ]
                    ),
                    .init(
                        rows: [
                            .init(configuration: .toggle(title: "Filter Lists", storage: \.$findingFilterLists))
                        ],
                        description: .constant(string: "Filter lists when typing in the search bar")
                    )
                ]
            )
        )
    }()

    static var highlightsPage: SettingsPage = {
        .init(
            title: "Highlights",
            configuration: .sections(
                sections: [
                    .init(
                        rows: [],
                        customViewIdentifier: .highlightsPreview
                    ),
                    .init(
                        rows: [
                            .init(configuration: .custom(identifier: .highlightsColor))
                        ],
                        description: .constant(string: "The default color for highlights.")
                    ),
                    .init(
                        rows: [
                            .init(configuration: .toggle(title: "Cycle Search Bar Colors", storage: \.$highlightsCycleSearchBarColors))
                        ],
                        description: .constant(string: "Automatically adjust the color of each additional search bar added.")
                    ),
                    .init(
                        header: "Border Width",
                        rows: [
                            .init(
                                configuration: .slider(
                                    numberOfSteps: nil,
                                    minValue: 0,
                                    maxValue: 4,
                                    minSymbol: .system(name: "line.diagonal", weight: .ultraLight),
                                    maxSymbol: .system(name: "line.diagonal", weight: .black),
                                    saveAsInt: false,
                                    storage: \.$highlightsBorderWidth
                                )
                            )
                        ]
                    ),
                    .init(
                        header: "Background Opacity",
                        rows: [
                            .init(
                                configuration: .slider(
                                    numberOfSteps: nil,
                                    minValue: 0,
                                    maxValue: 0.5,
                                    minSymbol: .system(name: "rectangle", weight: .regular),
                                    maxSymbol: .system(name: "rectangle.fill", weight: .regular),
                                    saveAsInt: false,
                                    storage: \.$highlightsBackgroundOpacity
                                )
                            )
                        ]
                    )
                ]
            )
        )
    }()
}
