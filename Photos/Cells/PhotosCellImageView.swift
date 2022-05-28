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
//    let state = getState()
//    let state = PhotosCellImageViewState()
    
    var body: some View {
        

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
//            .overlay(
//                Color.blue.opacity(state.showingBlueOverlay ? 1 : 0)
//            )
//            .overlay(
//                ZStack(alignment: .bottomLeading) {
//                    if state.showingShade {
//                        LinearGradient(
//                            stops: [
//                                .init(color: .clear, location: 0.6),
//                                .init(color: .black, location: 1)
//                            ],
//                            startPoint: .topLeading,
//                            endPoint: .bottomTrailing
//                        )
//                    }
//
//                    if state.showingStar {
//                        Image(systemName: "star.fill")
//                            .foregroundColor(.yellow)
//                    }
//                }
//            )
            .overlay(
                VStack {
                    if model.selected {
                        Circle()
                            .fill(.blue)
                            .frame(width: 12, height: 12)
                            .overlay(
                                Circle()
                                    .stroke(.white, lineWidth: 2)
                            )
                    }
                }
            )
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
