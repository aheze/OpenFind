//
//  SettingsFooter.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/6/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct SettingsFooter: View {
    @ObservedObject var model: SettingsViewModel
    @ObservedObject var realmModel: RealmModel

    var body: some View {
        HStack(spacing: 0) {
            Text(verbatim: "Version \(getVersionString())")
            Text(verbatim: " • ")
            Button {
                if let url = URL(string: "https://getfind.app/whatsnew/") {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text(verbatim: "See What's New")
                    .foregroundColor(UIColor.label.color)
            }
        }
        .foregroundColor(UIColor.secondaryLabel.color)
    }

    func getVersionString() -> String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
}
