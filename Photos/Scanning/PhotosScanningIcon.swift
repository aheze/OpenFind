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
                iconFont: .preferredCustomFont(forTextStyle: .caption2, weight: PhotosConstants.scanningCheckmarkWeight),
                state: model.scanningIconState
            )
                .padding(4)
                .padding(.leading, 8)
                .contentShape(Rectangle())
        }
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
