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
}

struct PhotosScanningIcon: View {
    @ObservedObject var model: PhotosViewModel

    var body: some View {
        Button {
            model.scanningIconTapped?()
        } label: {
            PhotosScanningProgressView(
                scannedPhotosCount: model.scannedPhotosCount,
                totalPhotosCount: model.totalPhotosCount,
                lineWidth: 2.5,
                iconFont: .systemFont(ofSize: 9, weight: PhotosConstants.scanningCheckmarkWeight),
                state: model.scanningIconState
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
    var scannedPhotosCount: Int
    var totalPhotosCount: Int
    var lineWidth: CGFloat
    var iconFont: UIFont
    var state: PhotosScanningIconState

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
            .animation(.spring(), value: scannedPhotosCount)
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
                VStack {
                    if state == .done {
                        Image(systemName: "checkmark")
                    } else if state == .paused {
                        Image(systemName: "pause.fill")
                    }
                }
                .font(Font(iconFont as CTFont))
                .foregroundColor(.accent)
            )
    }

    func getTrimPercentage() -> CGFloat {
        return CGFloat(scannedPhotosCount) / CGFloat(totalPhotosCount)
    }
}

struct PhotosScanningGradientProgressView: View {
    var scannedPhotosCount: Int
    var totalPhotosCount: Int
    var lineWidth: CGFloat
    var iconFont: UIFont
    var state: PhotosScanningIconState
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
            .animation(.spring(), value: scannedPhotosCount)
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
            )
            .overlay(
                VStack {
                    if state == .done {
                        Image(systemName: "checkmark")
                            .transition(
                                .asymmetric(
                                    insertion: .move(edge: .bottom),
                                    removal: .move(edge: .top)
                                )
                                .combined(with: .opacity)
                            )
                    } else if state == .paused {
                        Image(systemName: "pause.fill")
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
                .animation(.spring(), value: state)
            )
    }

    func getTrimPercentage() -> CGFloat {
        return CGFloat(scannedPhotosCount) / CGFloat(totalPhotosCount)
    }
}
