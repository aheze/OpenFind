//
//  SettingsHapticFeedback.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/5/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct SettingsHapticFeedback: View {
    @ObservedObject var model: SettingsViewModel
    @ObservedObject var realmModel: RealmModel

    var body: some View {
        
        HStack {
            ForEach(Settings.Values.HapticFeedbackLevel.allCases) { level in
                SettingsHapticFeedbackButton(model: model, realmModel: realmModel, level: level)
            }
        }
        .frame(height: 80)
        .frame(maxWidth: .infinity)
        .padding(SettingsConstants.rowHorizontalInsets)
        .padding(SettingsConstants.rowVerticalInsetsFromText)
    }
}

struct SettingsHapticFeedbackButton: View {
    @ObservedObject var model: SettingsViewModel
    @ObservedObject var realmModel: RealmModel
    
    let level: Settings.Values.HapticFeedbackLevel
    let cornerRadius = CGFloat(10)
    let lineWidth = CGFloat(4)

    var body: some View {
        Button {
            withAnimation {
                realmModel.hapticFeedbackLevel = level
            }
        } label: {
            UIColor.label.color.opacity(getBackgroundOpacity())
                .cornerRadius(cornerRadius)
                .overlay(
                    Text(level.rawValue)
                        .foregroundColor(UIColor.label.color)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(lineWidth: lineWidth)
                        .opacity(realmModel.hapticFeedbackLevel == level ? 1 : 0)
                )
        }
    }

    func getBackgroundOpacity() -> Double {
        switch level {
        case .none:
            return 0.05
        case .light:
            return 0.1
        case .heavy:
            return 0.14
        }
    }
}
