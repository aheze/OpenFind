//
//  CameraToolbarView.swift
//  Camera
//
//  Created by Zheng on 12/1/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

struct CameraToolbarView: View {
    @ObservedObject var model: CameraViewModel
    
    var body: some View {
        let flashEnabled = Binding {
            !model.shutterOn
        } set: { newValue in
            model.shutterOn = !newValue
        }

        HStack(alignment: .top, spacing: 0) {
            HStack {
                ResultsIconView(count: $model.resultsCount)
                Spacer()
                SnapshotView(model: model, isEnabled: $model.shutterOn)
            }
            .frame(maxWidth: .infinity)

            Color.clear

            HStack {
                FlashIconView(isOn: $model.flash, isEnabled: flashEnabled)
                Spacer()
                OpenSettingsIconView()
            }
            .frame(maxWidth: .infinity)
        }
    }
}


