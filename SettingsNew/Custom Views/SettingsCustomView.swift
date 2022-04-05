//
//  SettingsCustomView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct SettingsCustomView: View {
    @ObservedObject var model: SettingsViewModel
    let identifier: Settings.Identifier
    var body: some View {
        VStack {
            switch identifier {
            case .hapticFeedbackLevel:
                SettingsHapticFeedback(model: model)
            case .highlightsIcon:
                SettingsHighlightsIcon(model: model)
            case .highlightsColor:
                SettingsHighlightsColor(model: model)
            default:
                Text(verbatim: "Custom view: \(identifier)")
            }
        }
    }
}
