//
//  SettingsVM+Strings.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/5/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

extension Settings.StringIdentifier {
    func getString(realmModel: RealmModel) -> String {
        switch self {
        case .findingMatch:

            if realmModel.findingMatchCase {
                if realmModel.findingMatchAccents {
                    /// match both case and accents.
                    return "Case-and-accent sensitive search."
                } else {
                    /// match case, accents don't matter. Could be taxing on the CPU
                    return "Case-sensitive search. Tip: to optimize finding, also enable Match Accents."
                }
            } else {
                if realmModel.findingMatchAccents {
                    /// match accents but not case
                    return "Accent-sensitive search."
                } else {
                    /// don't match anything
                    return "Capitalization and accents won't matter."
                }
            }
        case .keepWhitespace:
            if realmModel.findingKeepWhitespace {
                return "Keep leading and trailing whitespace in entered text in the search bar. Also affects words inside lists."
            } else {
                return "Trim whitespace from entered text in the search bar. Also affects words inside lists."
            }
        case .filterLists:
            if realmModel.findingFilterLists {
                return "Filter lists when typing in the search bar."
            } else {
                return "Always show all lists in the search bar."
            }
        case .scanningFrequency:
            if let frequency = Settings.Values.ScanningFrequencyLevel(rawValue: realmModel.cameraScanningFrequency) {
                if frequency == .continuous {
                    return "Scan as often as possible in the live preview."
                } else {
                    let title = frequency.getTitle().lowercased()
                    return "Scan every \(title) in the live preview."
                }
            }
        case .pauseScanningAfter:
            if let duration = Settings.Values.ScanningDurationUntilPauseLevel(rawValue: realmModel.cameraScanningDurationUntilPause) {
                if duration == .never {
                    return "Never pause the live preview."
                } else {
                    let title = duration.getTitle().lowercased()
                    return "Pause the live preview after \(title) if no text is detected."
                }
            }
        case .cameraStabilizationMode:
            if let mode = Settings.Values.StabilizationMode(rawValue: realmModel.cameraStabilizationMode) {
                switch mode {
                case .off:
                    return "No video stabilization."
                case .standard:
                    return "Standard video stabilization — produces steadier frames, but narrows the FOV and could be slightly slower."
                case .cinematic:
                    return "Cinematic video stabilization — produces steadier frames, but narrows the FOV and will be slightly slower."
                case .cinematicExtended:
                    return "IT'S MORBIN' TIME!"
                case .auto:
                    return "Auto video stabilization based on device capabilities."
                }
            }
        case .photosResultsInsertNewMode:
            if let photosResultsInsertNewMode = Settings.Values.PhotosResultsInsertNewMode(rawValue: realmModel.photosResultsInsertNewMode) {
                switch photosResultsInsertNewMode {
                case .top:
                    return "Insert new results at the top of the list."
                case .bottom:
                    return "Insert new results at the bottom of the list"
                }
            }
        }

        return ""
    }
}
