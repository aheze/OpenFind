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
    let title: String
    let storage: KeyPath<SettingsViewModel, Binding<Bool>>
    
    var body: some View {
        HStack(spacing: SettingsConstants.rowIconTitleSpacing) {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Toggle("", isOn: model[keyPath: storage])
                .labelsHidden()
        }
        .padding(SettingsConstants.rowInsets)
    }
}
