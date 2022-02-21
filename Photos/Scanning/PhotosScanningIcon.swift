//
//  PhotosScanningIcon.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/18/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct PhotosScanningIcon: View {
    @ObservedObject var model: PhotosViewModel

    var body: some View {
        Button {
            model.scanningIconTapped?()
        } label: {
            PhotosScanningProgressView(
                scannedPhotosCount: model.scannedPhotosCount,
                totalPhotosCount: model.totalPhotosCount,
                lineWidth: 2.5
            )
                .contentShape(Rectangle())
        }
    }
}

struct PhotosScanningProgressView: View {
    var scannedPhotosCount: Int
    var totalPhotosCount: Int
    var lineWidth: CGFloat
    
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
    }

    func getTrimPercentage() -> CGFloat {
        return CGFloat(scannedPhotosCount) / CGFloat(totalPhotosCount)
    }
}
