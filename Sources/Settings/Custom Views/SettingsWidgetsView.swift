//
//  SettingsWidgetsView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 5/31/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct SettingsWidgetsView: View {
    @ObservedObject var model: SettingsViewModel
    @ObservedObject var realmModel: RealmModel

    var body: some View {
        Text("Widgets are only available in iOS 14+")
            .foregroundColor(.red)
    }
}
