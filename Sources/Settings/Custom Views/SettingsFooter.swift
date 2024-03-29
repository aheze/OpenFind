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
        VStack(spacing: 12) {
            Text("An [open-source](https://github.com/aheze/OpenFind) app by [Andrew Zheng](https://twitter.com/aheze0).")
                .accentColor(UIColor.label.color)
            
            HStack(spacing: 0) {
                Text(verbatim: "Version \(Utilities.getVersionString())")
                Text(verbatim: " • ")
                Button {
                    if let url = URL(string: "https://open.getfind.app/whatsnew") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text(verbatim: "See What's New")
                        .foregroundColor(UIColor.label.color)
                }
            }
        }
        .foregroundColor(UIColor.secondaryLabel.color)
    }

}
