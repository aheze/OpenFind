//
//  PhotosScanningIcon.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/18/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

enum PhotosScanningIconState {
    case scanning
    case paused
    case done

    func getDescription() -> String {
        switch self {
        case .scanning:
            return "Currently scanning"
        case .paused:
            return "Currently paused"
        case .done:
            return "Done scanning"
        }
    }
}

struct PhotosScanningIcon: View {
    @ObservedObject var model: PhotosViewModel

    var body: some View {
        Button {
            model.scanningIconTapped?()
        } label: {
            PhotosScanningProgressView(
                model: model,
                lineWidth: 2.5,
                iconFont: .systemFont(ofSize: 9, weight: PhotosConstants.scanningCheckmarkWeight)
            )
            .padding(4)
            .padding(.leading, 8)
            .contentShape(Rectangle())
        }
        .opacity(model.photosEditable ? 1 : 0.5)
        .disabled(!model.photosEditable)
    }
}

struct PhotosScanningProgressView: View {
    @ObservedObject var model: PhotosViewModel
    var lineWidth: CGFloat
    var iconFont: UIFont
    var showGradient = false

    @State var color = Colors.accent

    var body: some View {
        Circle()
            .trim(from: 0, to: getTrimPercentage())
            .stroke(
                Color.accent,
                style: StrokeStyle(
                    lineWidth: lineWidth,
                    lineCap: .round
                )
            )
            .animation(.spring(), value: model.scannedPhotosCount)
            .background(
                Circle()
                    .stroke(
                        Color.accent.opacity(0.25),
                        style: StrokeStyle(
                            lineWidth: lineWidth,
                            lineCap: .round
                        )
                    )
            )
            .rotationEffect(.degrees(-90))
            .overlay(
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                color.color,
                                color.offset(by: 0.01).withAlphaComponent(0.5).color
                            ],
                            startPoint: .bottomLeading,
                            endPoint: .topTrailing
                        )
                    )
                    .padding(lineWidth / 2)
                    .opacity(0.5)
                    .opacity(showGradient ? 1 : 0)
            )
            .overlay(
                VStack {
                    if model.notes.isEmpty {
                        switch model.scanningIconState {
                        case .scanning:
                            EmptyView()
                        case .done:
                            Image(systemName: "checkmark")
                                .transition(
                                    .asymmetric(
                                        insertion: .move(edge: .bottom),
                                        removal: .move(edge: .top)
                                    )
                                    .combined(with: .opacity)
                                )
                        case .paused:
                            Image(systemName: "pause.fill")
                                .transition(
                                    .asymmetric(
                                        insertion: .move(edge: .bottom),
                                        removal: .move(edge: .top)
                                    )
                                    .combined(with: .opacity)
                                )
                        }
                    } else {
                        Image(systemName: "exclamationmark")
                            .transition(
                                .asymmetric(
                                    insertion: .move(edge: .bottom),
                                    removal: .move(edge: .top)
                                )
                                .combined(with: .opacity)
                            )
                    }
                }
                .font(Font(iconFont as CTFont))
                .foregroundColor(.accent)
                .animation(.spring(), value: model.scanningIconState)
            )
            .accessibilityLabel(model.scanningIconState.getDescription())
    }

    func getTrimPercentage() -> CGFloat {
        return CGFloat(model.scannedPhotosCount) / CGFloat(model.totalPhotosCount)
    }
}
