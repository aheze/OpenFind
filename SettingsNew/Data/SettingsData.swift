//
//  SettingsData.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct SettingsData {
    static var showScanningOptions: (() -> Void)?
    
    static var mainPage: SettingsPage = .init(
        title: "Main Settings",
        configuration: .sections(sections: mainSections),
        bottomViewIdentifier: nil,
        addTopPadding: false
    )

    static var mainSections: [SettingsSection] = {
        [
            /// general section
            generalSection,

            /// finding and highlights (second section)
            findingAndHighlightsSection,

            /// photos, camera, lists
            tabsSection
        ]
    }()
}
