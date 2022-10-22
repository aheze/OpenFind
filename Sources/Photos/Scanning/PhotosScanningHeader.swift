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
        HStack(spacing: 12) {
            PhotosScanningProgressView(
                model: model,
                lineWidth: 4,
                iconFont: .systemFont(ofSize: 15, weight: .semibold)
            )
            .frame(width: 26, height: 26)

            let time = model.getRemainingTime()

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
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(UIFont.preferredCustomFont(forTextStyle: .title1, weight: .semibold).font)

                if let time = time {
                    if model.scanningState == .dormant {
                        Text("Paused")
                            .font(.body.weight(.semibold))
                            .foregroundColor(.red)
                    } else {
                        Text("~\(time)")
                            .font(.body.weight(.semibold))
                            .foregroundColor(.accent)
                    }
                }
            }
        }
    }
}
