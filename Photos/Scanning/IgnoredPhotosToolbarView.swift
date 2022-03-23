//
//  IgnoredPhotosToolbarView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/23/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

enum UnignoreAction {
    case unignoreAll
    case unignoreSelected([Photo])
}

struct IgnoredPhotosToolbarView: View {
    @ObservedObject var model: PhotosViewModel
    @State var showingWarning = false
    
    var body: some View {
        let action = getUnignoreAction()
        let text = getText()
        Button {
            switch action {
            case .unignoreAll:
                showingWarning = true

            case .unignoreSelected(let selectedPhotos):
                for photo in selectedPhotos {
                    var newPhoto = photo
                    newPhoto.metadata?.isIgnored = false
                    model.updatePhotoMetadata(photo: newPhoto, reloadCell: false)
                }
                model.ignoredPhotosUpdated?()
            }

        } label: {
            Text(text)
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
        .actionSheet(isPresented: $showingWarning) {
            ActionSheet(
                title: Text("All photos will be unignored."),
                buttons: [
                    .default(Text("Unignore All Photos")) {
                        for photo in model.ignoredPhotos {
                            var newPhoto = photo
                            newPhoto.metadata?.isIgnored = false
                            model.updatePhotoMetadata(photo: newPhoto, reloadCell: false)
                        }
                        model.ignoredPhotosUpdated?()
                    },
                    .cancel()
                ]
            )
        }
    }

    func getUnignoreAction() -> UnignoreAction {
        switch model.ignoredPhotosSelectedPhotos.count {
        case 0:
            return .unignoreAll
        default:
            return .unignoreSelected(model.ignoredPhotosSelectedPhotos)
        }
    }

    func getText() -> String {
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
