//
//  SettingsData.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct SettingsData {
    // MARK: Set this inside the actual app

    static var showScanningOptions: (() -> Void)?
    static var exportAllLists: (() -> Void)?
    static var deleteAllScannedData: (() -> Void)?
    
    // MARK: Internal callback

    static var resetAllSettings: (() -> Void)?
    /// feedback
    static var rateTheApp: (() -> Void)?
    static var reportABug: (() -> Void)?
    static var suggestNewFeatures: (() -> Void)?
    static var helpCenter: (() -> Void)?
    static var joinTheDiscord: (() -> Void)?
    static var joinTheReddit: (() -> Void)?
    static var translateFind: (() -> Void)?
    static var shareApp: (() -> Void)?
    
    static var getHelpCenter: (() -> UIViewController?)?
    
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
            
            /// widgets
//            moreSection,
            
            /// rate, report, suggest
            feedbackSection,
            
            /// help, Discord, Reddit, share
            linksSection,
            
            /// credits, licenses
            aboutSection,
            
            /// what's new
            footerSection
        ]
    }()
}
