//
//  PhotosScanningHeader.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/15/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct PhotosScanningHeader: View {
    @ObservedObject var model: PhotosViewModel
    var body: some View {
        Button {
            model.scanningIconTapped?()
        } label: {
            HStack(spacing: 12) {
                PhotosScanningProgressView(
                    scannedPhotosCount: model.scannedPhotosCount,
                    totalPhotosCount: model.totalPhotosCount,
                    lineWidth: 4,
                    iconFont: .preferredCustomFont(forTextStyle: .footnote, weight: PhotosConstants.scanningCheckmarkWeight),
                    state: model.scanningIconState
                )
                .frame(width: 32, height: 32)

                VStack(alignment: .leading, spacing: 5) {
                    let time = model.getRemainingTime()

                    Text(time == nil ? "All Photos Scanned" : "Scanning Photos...")
                        .font(.body.weight(.semibold))
                        .foregroundColor(.accent)

                    HStack {
                        Group {
                            Text("\(model.scannedPhotosCount)")
                                .foregroundColor(.accent)
                                +
                                Text("/")
                                .foregroundColor(.accent.opacity(0.75))
                                +
                                Text("\(model.totalPhotosCount)")
                                .foregroundColor(.accent.opacity(0.75))
                        }
                        .font(Font(UIFont.preferredCustomFont(forTextStyle: .title3, weight: .semibold) as CTFont))

                        Spacer()

                        if let time = time {
                            Text(time)
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.accent)
                        }
                    }
                }
            }
            .padding(PhotosScanningConstants.padding)
            .blueBackground()
        }
    }
}
