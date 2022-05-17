//
//  SettingsDefaultTabView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/10/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct SettingsDefaultTabView: View {
    @ObservedObject var model: SettingsViewModel
    @ObservedObject var realmModel: RealmModel

    var body: some View {
        HStack {
            ForEach(Settings.Values.Tab.allCases) { tab in
                SettingsDefaultTabViewButton(model: model, realmModel: realmModel, tab: tab) {
                    VStack {
                        switch tab {
                        case .photos:
                            Image("Photos")
                            Text("Photos")
                            
                        case .camera:
                            Image("Camera")
                            Text("Camera")
                            
                        case .lists:
                            Image("Lists")
                            Text("Lists")
                        }
                    }
                    .foregroundColor(getColor(for: tab))
                    .padding(12)
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(SettingsConstants.rowHorizontalInsets)
        .padding(SettingsConstants.rowVerticalInsetsFromText)
    }

    func getColor(for tab: Settings.Values.Tab) -> Color {
        if tab == realmModel.defaultTab {
            return Color.accent
        } else {
            return UIColor.secondaryLabel.color
        }
    }
}

struct SettingsDefaultTabViewButton<Content: View>: View {
    @ObservedObject var model: SettingsViewModel
    @ObservedObject var realmModel: RealmModel
    var tab: Settings.Values.Tab
    @ViewBuilder let content: Content

    let cornerRadius = CGFloat(10)
    let lineWidth = CGFloat(4)

    var body: some View {
        Button {
            realmModel.defaultTab = tab
        } label: {
            content
                .frame(maxWidth: .infinity)
                .background(
                    VStack {
                        if realmModel.defaultTab == tab {
                            Color.accent.opacity(0.1)
                        } else {
                            UIColor.secondarySystemBackground.color
                        }
                    }
                    .cornerRadius(cornerRadius)
                )
        }
    }
}
