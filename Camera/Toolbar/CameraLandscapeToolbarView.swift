//
//  CameraLandscapeToolbarView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/8/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct CameraLandscapeToolbarView: View {
    @ObservedObject var tabViewModel: TabViewModel
    @ObservedObject var model: CameraViewModel
    var sizeChanged: ((CGSize) -> Void)?

    var body: some View {
        Color.clear.overlay(
            VStack {
                if model.toolbarState == .sideCompact {
                    HStack {
                        ResultsIconView(model: model)
                            .frameTag(CameraStatusConstants.landscapeSourceViewIdentifier)
                        SnapshotView(model: model, isEnabled: $model.shutterOn)
                    }
                } else {
                    ResultsIconView(model: model)
                        .frameTag(CameraStatusConstants.landscapeSourceViewIdentifier)
                    SnapshotView(model: model, isEnabled: $model.shutterOn)
                }

                CameraButton(tabViewModel: tabViewModel, cameraViewModel: model, attributes: tabViewModel.cameraLandscapeIconAttributes)

                if model.toolbarState == .sideCompact {
                    HStack {
                        FlashIconView(model: model, isEnabled: !model.shutterOn)
                        OpenSettingsIconView(model: model)
                    }
                } else {
                    FlashIconView(model: model, isEnabled: !model.shutterOn)
                    OpenSettingsIconView(model: model)
                }
            }
            .readSize {
                sizeChanged?($0)
            }
        )
        .edgesIgnoringSafeArea(.all)
    }
}

struct CameraLandscapeToolbarViewTester: View {
    @StateObject var tabViewModel = TabViewModel()
    @StateObject var model = CameraViewModel()
    var body: some View {
        CameraLandscapeToolbarView(tabViewModel: tabViewModel, model: model)
            .background(Color.black)
            .onAppear {
                model.toolbarState = .sideCompact
            }
    }
}

struct CameraLandscapeToolbarView_Previews: PreviewProvider {
    static var previews: some View {
        CameraLandscapeToolbarViewTester()
    }
}
