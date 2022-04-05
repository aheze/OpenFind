//
//  SettingsResultsView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import SwiftUI


struct SettingsResultsView: View {
    var paths: [[SettingsRow]]
    var sizeChanged: ((CGSize) -> Void)?
    var body: some View {
        Text("Settings Results")
            .fixedSize(horizontal: false, vertical: true)
            .padding()
            .background(Color.accent.opacity(0.1))
            .cornerRadius(16)
            .padding()
            .readSize {
                self.sizeChanged?($0)
            }
    }
}
