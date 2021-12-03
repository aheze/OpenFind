//
//  CameraToolbarView.swift
//  Camera
//
//  Created by Zheng on 12/1/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

struct CameraToolbarView: View {
    @ObservedObject var viewModel: ToolbarViewModel.Camera
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            HStack {
                ResultsIconView(count: $viewModel.resultsCount)
                Spacer()
                SnapshotView(done: $viewModel.snapshotSaved)
            }
            .frame(maxWidth: .infinity)

            Color.clear

            HStack {
                FlashIconView(isOn: $viewModel.flash)
                Spacer()
                SettingsIconView()
            }
            .frame(maxWidth: .infinity)
        }
    }
}
