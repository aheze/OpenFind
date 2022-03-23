//
//  IgnoredPhotosToolbarView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/23/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct IgnoredPhotosToolbarView: View {
    @ObservedObject var model: PhotosViewModel

    var body: some View {
        Button {} label: {
            Text(text())
                .padding()
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .background(
                    VisualEffectView(.regular)
                        .overlay(
                            Color.clear
                                .border( /// border is less glitchy than overlay
                                    Color(UIColor.opaqueSeparator),
                                    width: 0.25
                                )
                                .padding(-0.25)
                        )
                        .edgesIgnoringSafeArea(.all)
                )
        }
    }

    func text() -> String {
        switch model.ignoredPhotosSelectedPhotos.count {
        case 0:
            return "Unignore All Photos"
        case 1:
            return "Unignore \(model.ignoredPhotosSelectedPhotos.count) Photo"
        default:
            return "Unignore \(model.ignoredPhotosSelectedPhotos.count) Photos"
        }
    }
}
