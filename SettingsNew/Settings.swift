//
//  Settings.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/5/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Foundation

enum Settings {
    /// for the view
    enum Identifier: String {
        case hapticFeedbackLevel
        
        case highlightsIcon
        case highlightsColor
        case highlightsBorderWidth
        case highlightsBackgroundOpacity
    }

    /// for storage
    enum Values {
        enum HapticFeedbackLevel: String, CaseIterable, Identifiable {
            var id: Self { self }
            
            case none
            case light
            case heavy
        }
    }
}
