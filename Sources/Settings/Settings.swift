//
//  Settings.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/5/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import AVFoundation
import UIKit

enum Settings {
    /// for views
    enum ViewIdentifier: String {
        case defaultTab

        case highlightsPreview
        case highlightsIcon
        case highlightsColor

        case photosGridSize

        case cameraHapticFeedbackLevel

        case widgets

        case credits
        case licenses

        case footer
    }

    enum DynamicPickerIdentifier {
        case primaryRecognitionLanguage
        case secondaryRecognitionLanguage
    }

    enum StringIdentifier {
        case findingMatch
        case keepWhitespace
        case filterLists
        case scanningFrequency
        case cameraStabilizationMode
        case pauseScanningAfter
        case photosResultsInsertNewMode
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

            func getFeedbackStyle() -> UIImpactFeedbackGenerator.FeedbackStyle? {
                switch self {
                case .none:
                    return nil
                case .light:
                    return .light
                case .heavy:
                    return .medium
                }
            }
        }

        enum PhotosResultsCellLayout: String, CaseIterable, Identifiable {
            var id: Self { self }

            case small
            case medium
            case large

            func getTitle() -> String {
                switch self {
                case .small:
                    return "Small"
                case .medium:
                    return "Medium"
                case .large:
                    return "Large"
                }
            }

            func getCellHeight() -> CGFloat {
                switch self {
                case .small:
                    return 60
                case .medium:
                    return 90
                case .large:
                    return 300
                }
            }
        }

        enum PhotosResultsInsertNewMode: String, CaseIterable, Identifiable {
            var id: Self { self }

            case top /// new results get inserted at top
            case bottom /// inserted at bottom

            func getTitle() -> String {
                switch self {
                case .top:
                    return "Top"
                case .bottom:
                    return "Bottom"
                }
            }
        }

        enum ScanningDurationUntilPauseLevel: String, CaseIterable, Identifiable {
            var id: Self { self }

            case never = ""
            case fiveSeconds = "5"
            case tenSeconds = "10"
            case thirtySeconds = "30"
            case sixtySeconds = "60"

            func getDouble() -> Double? {
                switch self {
                case .never:
                    return nil
                case .fiveSeconds:
                    return 5
                case .tenSeconds:
                    return 10
                case .thirtySeconds:
                    return 30
                case .sixtySeconds:
                    return 60
                }
            }

            func getTitle() -> String {
                switch self {
                case .never:
                    return "Never"
                case .fiveSeconds:
                    return "5 Seconds"
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
            case tenthSecond = "0.1"
            case quarterSecond = "0.25"
            case halfSecond = "0.5"
            case threeQuartersSecond = "0.75"
            case oneSecond = "1"

            func getDouble() -> Double {
                switch self {
                case .continuous:
                    return 0
                case .tenthSecond:
                    return 0.1
                case .quarterSecond:
                    return 0.25
                case .halfSecond:
                    return 0.5
                case .threeQuartersSecond:
                    return 0.75
                case .oneSecond:
                    return 1
                }
            }

            func getTitle() -> String {
                switch self {
                case .continuous:
                    return "Continuous"
                case .tenthSecond:
                    return "0.1 Seconds"
                case .quarterSecond:
                    return "0.25 Seconds"
                case .halfSecond:
                    return "0.5 Seconds"
                case .threeQuartersSecond:
                    return "0.75 Seconds"
                case .oneSecond:
                    return "1 Second"
                }
            }
        }

        enum StabilizationMode: String, CaseIterable, Identifiable {
            var id: Self { self }

            case off
            case standard
            case cinematic
            case cinematicExtended
            case auto

            func getAVCaptureVideoStabilizationMode() -> AVCaptureVideoStabilizationMode {
                switch self {
                case .off:
                    return .off
                case .standard:
                    return .standard
                case .cinematic:
                    return .cinematic
                case .cinematicExtended:
                    return .cinematicExtended
                case .auto:
                    return .auto
                }
            }

            func getTitle() -> String {
                switch self {
                case .off:
                    return "Off"
                case .standard:
                    return "Standard"
                case .cinematic:
                    return "Cinematic"
                case .cinematicExtended:
                    return "Cinematic Extended"
                case .auto:
                    return "Auto"
                }
            }
        }

        enum ListsSortByLevel: String, CaseIterable, Identifiable {
            var id: Self { self }

            case newestFirst
            case oldestFirst
            case title
        }
    }
}
