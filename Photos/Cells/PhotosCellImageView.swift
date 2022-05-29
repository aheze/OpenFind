//
//  PhotosCellImageView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 5/27/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct PhotosCellImageViewState {
    var showingShade = false
    var showingStar = false
    var showingBlueOverlay = false
}

struct PhotosCellImageView: View {
    @ObservedObject var model: PhotosCellImageViewModel

    var body: some View {
        let state = getState()

        Color.clear
            .overlay(
                VStack {
                    if let image = model.image {
                        Color.clear.overlay(
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        )
                        .clipped()
                    }
                }
            )
            .overlay(
                Colors.accent.toColor(.black, percentage: 0.5).color
                    .opacity(state.showingBlueOverlay ? 0.75 : 0)
            )
            .overlay(
                ZStack(alignment: .bottomLeading) {
                    if state.showingShade {
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 0.3),
                                .init(color: .black, location: 1)
                            ],
                            startPoint: .topTrailing,
                            endPoint: .bottomLeading
                        )
                    }

                    if state.showingStar {
                        Image(systemName: "star.fill")
                            .font(UIFont.preferredFont(forTextStyle: .body).font)
                            .foregroundColor(.white)
                            .padding(6)
                    }
                }
                .opacity(model.showOverlay ? 1 : 0)
            )
            .overlay(
                ZStack(alignment: .bottomTrailing) {
                    Color.white
                        .opacity(model.showSelectionOverlay ? 0.1 : 0)

                    VStack {
                        if model.selected {
                            Circle()
                                .fill(.blue)
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Circle()
                                        .stroke(.white, lineWidth: 1.6)
                                )
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.white)
                                        .font(.system(size: 11, weight: .medium))
                                )
                        }
                    }
                    .padding(6)
                }
            )
            .edgesIgnoringSafeArea(.all)
            .opacity(model.show ? 1 : 0)
    }

    func getState() -> PhotosCellImageViewState {
        var state = PhotosCellImageViewState()
        if let metadata = model.photo?.metadata {
            state.showingBlueOverlay = metadata.isIgnored
            state.showingShade = metadata.isStarred
            state.showingStar = metadata.isStarred

            /// make set to reset if metadata doesn't exist - cells get reused
        } else {
            state.showingBlueOverlay = false
            state.showingShade = false
            state.showingStar = false
        }

        return state
    }
}
