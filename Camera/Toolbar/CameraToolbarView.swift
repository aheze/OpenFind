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
        HStack(alignment: .top, spacing: 0) {
            HStack {
                ResultsIconView(model: model)
                    .frameTag(CameraStatusConstants.sourceViewIdentifier)
                
                Spacer()
                SnapshotView(model: model, isEnabled: $model.shutterOn)
            }
            .frame(maxWidth: .infinity)

            Color.clear

            HStack {
                FlashIconView(model: model, isEnabled: !model.shutterOn)
                Spacer()
                OpenSettingsIconView(model: model)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
