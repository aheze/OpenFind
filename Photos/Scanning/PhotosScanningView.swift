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
    @ObservedObject var realmModel: RealmModel
    var body: some View {
        PhotosScanningViewHeader(model: model, realmModel: realmModel)
    }
}

struct PhotosScanningViewHeader: View {
    @ObservedObject var model: PhotosViewModel
    @ObservedObject var realmModel: RealmModel

    var body: some View {
        ScrollView {
            VStack(spacing: SettingsConstants.sectionSpacing) {
                /// Header
                Container(description: "Find works completely offline, so your photos and other data never leave your phone.") {
                    HStack(spacing: 16) {
                        PhotosScanningGradientProgressView(
                            scannedPhotosCount: model.scannedPhotosCount,
                            totalPhotosCount: model.totalPhotosCount,
                            lineWidth: 10,
                            iconFont: .systemFont(ofSize: 42, weight: PhotosConstants.scanningCheckmarkWeight),
                            state: model.scanningIconState
                        )
                        .frame(width: 90, height: 90)
                        .padding(20)
                        .frame(maxHeight: .infinity)
                        .blueBackground()

                        VStack(alignment: .leading) {
                            Text(getRemainingTime())
                                .foregroundColor(.accent.opacity(0.75))
                                .font(.headline.weight(.medium))
                                .accessibilityLabel(getRemainingTime(addTilde: false))

                            HStack {
                                Text("\(model.scannedPhotosCount)")
                                    .foregroundColor(.accent)
                                    +
                                    Text("/")
                                    .foregroundColor(.accent.opacity(0.75))
                                    +
                                    Text("\(model.totalPhotosCount)")
                                    .foregroundColor(.accent.opacity(0.75))
                            }
                            .font(.largeTitle.weight(.semibold))
                            .accessibilityLabel("\(model.scannedPhotosCount) out of \(model.totalPhotosCount)")

                            let image = getImage()
                            let title = getTitle()

                            PhotosScanningButton(image: image, title: title) {
                                guard model.scannedPhotosCount < model.totalPhotosCount else { return }

                                if model.scanningState == .dormant {
                                    model.startScanning()
                                } else {
                                    model.pauseScanning()
                                }
                            }
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(16)
                    .blueBackground()
                }

                PhotoScanningLink(
                    model: model,
                    title: "Ignored Photos",
                    arrowLabel: "\(model.ignoredPhotos.count)",
                    description: "Choose which photos to never scan."
                ) {
                    model.ignoredPhotosTapped?()
                }

                PhotoScanningRow(
                    realmModel: realmModel,
                    title: "Scan on Launch",
                    description: "Automatically scan photos as soon as you open the app.",
                    storage: \.$photosScanOnLaunch
                )

                PhotoScanningRow(
                    realmModel: realmModel,
                    title: "Scan on Find",
                    description: "Automatically scan photos when you type in the search bar.",
                    storage: \.$photosScanOnFind
                )

                PhotoScanningRow(
                    realmModel: realmModel,
                    title: "Scan New Photos",
                    description: "Automatically scan new photos when finding.",
                    storage: \.$photosScanOnAddition
                )

                Spacer()
            }
            .padding(SettingsConstants.edgeInsets)
        }
    }

    func getRemainingTime(addTilde: Bool = true) -> String {
        if let remainingTime = model.getRemainingTime() {
            if addTilde {
                return "~\(remainingTime)"
            } else {
                return remainingTime
            }
        } else {
            return "All Photos Scanned"
        }
    }

    func getImage() -> String {
        var image = model.scanningState == .scanningAllPhotos ? "pause.fill" : "play.fill"
        if model.scannedPhotosCount == model.totalPhotosCount {
            image = "checkmark"
        }
        return image
    }

    func getTitle() -> String {
        var title = model.scanningState == .scanningAllPhotos ? "Pause" : "Resume"
        if model.scannedPhotosCount == model.totalPhotosCount {
            title = "Scanning Done"
        }
        return title
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
            .cornerRadius(10)
        }
        .buttonStyle(EasingScaleButtonStyle())
    }
}

struct Container<Content: View>: View {
    var description: String
    @ViewBuilder let content: Content

    var body: some View {
        /// encompass each section
        VStack(spacing: 0) {
            content

            Text(description)
                .settingsDescriptionStyle()
        }
    }
}

struct PhotoScanningLink: View {
    @ObservedObject var model: PhotosViewModel
    var title: String
    var arrowLabel: String /// usually a number
    var description: String
    var action: () -> Void

    var body: some View {
        Container(description: description) {
            Button(action: action) {
                HStack {
                    Text(title)
                        .foregroundColor(UIColor.label.color)
                        .padding(SettingsConstants.rowVerticalInsetsFromText)

                    Spacer()

                    HStack {
                        Text(arrowLabel)
                        Image(systemName: "chevron.forward")
                    }
                    .foregroundColor(UIColor.secondaryLabel.color)
                }
                .padding(SettingsConstants.rowHorizontalInsets)
            }
            .buttonStyle(SettingsButtonStyle())
            .background(UIColor.systemBackground.color)
            .cornerRadius(SettingsConstants.sectionCornerRadius)
        }
    }
}

struct PhotoScanningRow: View {
    @ObservedObject var realmModel: RealmModel
    var title: String
    var description: String
    var storage: KeyPath<RealmModel, Binding<Bool>>

    var body: some View {
        Container(description: description) {
            SettingsToggle(
                realmModel: realmModel,
                title: title,
                storage: storage
            )
            .background(UIColor.systemBackground.color)
            .cornerRadius(SettingsConstants.sectionCornerRadius)
        }
    }
}
