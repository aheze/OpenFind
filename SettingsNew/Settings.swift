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
        case defaultTab

        case highlightsPreview
        case highlightsIcon
        case highlightsColor

        case cameraHapticFeedbackLevel

        case photosGridSize

        case credits
        case licenses

        case links
        case footer
    }

    enum DynamicPickerIdentifier {
        case primaryRecognitionLanguage
        case secondaryRecognitionLanguage
    }

    enum StringIdentifier {
        case keepWhitespace
        case filterLists
        case pauseScanningAfter
    }

    /// for storage
    enum Values {
        enum RecognitionLanguage: String, CaseIterable, Identifiable {
            var id: Self { self }
            case none = ""
            case english = "en-US"
            case french = "fr-FR"
            case italian = "it-IT"
            case german = "de-DE"
            case spanish = "es-ES"
            case portuguese = "pt-BR"
            case chineseSimplified = "zh-Hans"
            case chineseTraditional = "zh-Hant"

            func getTitle() -> String {
                switch self {
                case .none:
                    return "None"
                case .english:
                    return "English"
                case .french:
                    return "French"
                case .italian:
                    return "Italian"
                case .german:
                    return "German"
                case .spanish:
                    return "Spanish"
                case .portuguese:
                    return "Portuguese"
                case .chineseSimplified:
                    return "Chinese (Simplified)"
                case .chineseTraditional:
                    return "Chinese (Traditional)"
                }
            }

            /// check if a language is available
            func isAvailableFor(accurateMode: Bool, version: Int) -> Bool {
                guard self != .none else { return false }

                if !accurateMode, requiresAccurateMode() {
                    return false
                }

                if version < versionNeeded() {
                    return false
                }

                return true
            }

            func versionNeeded() -> Int {
                switch self {
                case .none:
                    return 0
                case .english:
                    return 13
                case .french:
                    return 14
                case .italian:
                    return 14
                case .german:
                    return 14
                case .spanish:
                    return 14
                case .portuguese:
                    return 14
                case .chineseSimplified:
                    return 14
                case .chineseTraditional:
                    return 14
                }
            }

            func requiresAccurateMode() -> Bool {
                switch self {
                case .none:
                    return false
                case .english:
                    return false
                case .french:
                    return false
                case .italian:
                    return false
                case .german:
                    return false
                case .spanish:
                    return false
                case .portuguese:
                    return false
                case .chineseSimplified:
                    return true
                case .chineseTraditional:
                    return true
                }
            }
        }

        enum Tab: String, CaseIterable, Identifiable {
            var id: Self { self }

            case photos
            case camera
            case lists

            func getTitle() -> String {
                switch self {
                case .photos:
                    return "Photos"
                case .camera:
                    return "Camera"
                case .lists:
                    return "Lists"
                }
            }
        }

        enum HapticFeedbackLevel: String, CaseIterable, Identifiable {
            var id: Self { self }

            case none
            case light
            case heavy

            func getTitle() -> String {
                switch self {
                case .none:
                    return "None"
                case .light:
                    return "Light"
                case .heavy:
                    return "Heavy"
                }
            }
        }

        enum ScanningDurationUntilPauseLevel: String, CaseIterable, Identifiable {
            var id: Self { self }

            case never = "0"
            case tenSeconds = "10"
            case thirtySeconds = "30"
            case sixtySeconds = "60"
            
            func getTitle() -> String {
                switch self {
                case .never:
                    return "Never"
                case .tenSeconds:
                    return "10 Seconds"
                case .thirtySeconds:
                    return "30 Seconds"
                case .sixtySeconds:
                    return "1 Minute"
                }
            }
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

            case newestFirst
            case oldestFirst
            case title
        }
    }
}
