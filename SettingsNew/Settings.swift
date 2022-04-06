//
//  Settings.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/5/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Foundation

enum Settings {
    /// for views
    enum ViewIdentifier: String {
        case hapticFeedbackLevel

        case highlightsPreview
        case highlightsIcon
        case highlightsColor
        
        case photosGridSize
    }

    enum StringIdentifier: String {
        case asd
    }

    /// for storage
    enum Values {
        enum HapticFeedbackLevel: String, CaseIterable, Identifiable {
            var id: Self { self }

            case none
            case light
            case heavy
        }
        
        enum PauseScanningAfterLevel: String, CaseIterable, Identifiable {
            var id: Self { self }

            case never = "0"
            case tenSeconds = "10"
            case thirtySeconds = "30"
            case sixtySeconds = "60"
        }
    }
}


