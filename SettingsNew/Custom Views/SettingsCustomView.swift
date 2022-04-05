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
    let identifier: Settings.ViewIdentifier
    var body: some View {
        VStack {
            switch identifier {
            case .hapticFeedbackLevel:
                SettingsHapticFeedback(model: model)
            case .highlightsPreview:
                SettingsHighlightsPreview(model: model)
            case .highlightsIcon:
                SettingsHighlightsIcon(model: model)
            case .highlightsColor:
                SettingsHighlightsColor(model: model)
            }
        }
    }
}
