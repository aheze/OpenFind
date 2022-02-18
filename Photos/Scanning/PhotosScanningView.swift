//
//  PhotosScanningView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/18/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct PhotosScanningView: View {
    @ObservedObject var model: PhotosViewModel
    var body: some View {
        PhotosScanningViewHeader(model: model)
    }
}

struct PhotosScanningViewHeader: View {
    @ObservedObject var model: PhotosViewModel

    var body: some View {
        ScrollView {
            VStack {
                VStack(spacing: 15) {
                    HStack(spacing: 12) {
                        PhotosScanningProgressView(model: model, lineWidth: 4)
                            .frame(width: 32, height: 32)

                        HStack {
                            Text("\(model.scanningState.scannedPhotosCount)")
                                .foregroundColor(.accent)
                                +
                                Text("/")
                                .foregroundColor(.accent.opacity(0.75))
                                +
                                Text("\(model.scanningState.totalPhotosCount)")
                                .foregroundColor(.accent.opacity(0.75))
                            
                            Text("Scanned")
                                .foregroundColor(.accent.opacity(0.75))
                                .font(.largeTitle.weight(.regular))
                        }
                        .font(.largeTitle.weight(.semibold))

                        Spacer()
                    }

                    HStack {
                        PhotosScanningButton(image: "pause.fill", title: "Pause") {}

                        PhotosScanningButton(image: "speedometer", title: "Turbo") {}
                    }
                }
                .padding(PhotosScanningConstants.padding)
                .background(Color.accent.opacity(0.1))
                .cornerRadius(PhotosScanningConstants.cornerRadius)

                Spacer()
            }
            .padding(PhotosScanningConstants.padding)
        }
    }
}

struct PhotosScanningButton: View {
    var image: String?
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if let image = image {
                    Image(systemName: image)
                }

                Text(title)
            }
            .foregroundColor(Color.accent)
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(Color.accent.opacity(0.15))
            .cornerRadius(PhotosScanningConstants.innerCornerRadius)
        }
    }
}
