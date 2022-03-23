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
                    lineWidth: 3,
                    iconFont: .preferredCustomFont(forTextStyle: .footnote, weight: .semibold),
                    state: model.scanningIconState
                )
                .frame(width: 26, height: 26)

                VStack(alignment: .leading, spacing: 5) {
                    Text("SCANNING PHOTOS")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.accent)

                    HStack {
                        Text("\(model.scannedPhotosCount)")
                            .foregroundColor(.accent)
                            +
                            Text("/")
                            .foregroundColor(.accent.opacity(0.75))
                            +
                            Text("\(model.totalPhotosCount)")
                            .foregroundColor(.accent.opacity(0.75))

                        Spacer()

                        Text("~3 min left")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.accent)
                    }
                }
            }
            .padding(PhotosScanningConstants.padding)
            .blueBackground()
        }
    }
}
