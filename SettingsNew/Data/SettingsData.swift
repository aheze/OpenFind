//
//  SettingsData.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct SettingsData {
    
    /// set this inside the actual app
    static var showScanningOptions: (() -> Void)?
    static var exportAllLists: (() -> Void)?
    static var deleteAllPhotoMetadata: (() -> Void)?
    
    /// feedback
    static var rateTheApp: (() -> Void)?
    static var reportABug: (() -> Void)?
    static var suggestNewFeatures: (() -> Void)?
    static var helpCenter: (() -> Void)?
    static var joinTheDiscord: (() -> Void)?
    
    /// sharing
    static var shareLink: (() -> Void)?
    
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
            tabsSection,
            
            /// rate, report, suggest, help, Discord
            feedbackSection,
            
            /// credits, licenses
            aboutSection,
            
            /// share app
            linksSection,
            
            /// what's new
            footerSection
        ]
    }()
}
