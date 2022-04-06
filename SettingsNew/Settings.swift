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
        
        case credits
        case licenses
        case links
    }

    enum StringIdentifier: String {
        case asd
    }

    /// for storage
    enum Values {
        enum HapticFeedbackLevel: String, CaseIterable, Identifiable {
            var id: Self { self }

            case none = "None"
            case light = "Light"
            case heavy = "Heavy"
        }

        enum ScanningDurationUntilPauseLevel: String, CaseIterable, Identifiable {
            var id: Self { self }

            case never = "0"
            case tenSeconds = "10"
            case thirtySeconds = "30"
            case sixtySeconds = "60"
        }

        enum ScanningFrequencyLevel: String, CaseIterable, Identifiable {
            var id: Self { self }

            case continuous = "0"
            case halfSecond = "0.5"
            case oneSecond = "1"
            case twoSeconds = "2"
            case threeSeconds = "3"
        }

        enum ListsSortByLevel: String, CaseIterable, Identifiable {
            var id: Self { self }

            case newestFirst = "newestFirst"
            case oldestFirst = "oldestFirst"
            case title = "title"

        }
    }
}
