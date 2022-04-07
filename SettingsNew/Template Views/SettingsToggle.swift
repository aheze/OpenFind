//
//  SettingsToggle.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import SwiftUI

struct SettingsToggle: View {
    @ObservedObject var model: SettingsViewModel
    @ObservedObject var realmModel: RealmModel
    let title: String
    let storage: KeyPath<RealmModel, Binding<Bool>>
    
    var body: some View {
        HStack(spacing: SettingsConstants.rowIconTitleSpacing) {
            Text(title)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(SettingsConstants.rowVerticalInsetsFromText)
            
            Toggle("", isOn: realmModel[keyPath: storage])
                .labelsHidden()
        }
        .padding(SettingsConstants.rowHorizontalInsets)
    }
}
