//
//  PhotosSlidesInfoView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Photos
import SwiftUI

struct PhotosSlidesInfoView: View {
    @ObservedObject var model: PhotosViewModel
    @ObservedObject var realmModel: RealmModel
    @ObservedObject var infoModel: PhotoSlidesInfoViewModel
    @ObservedObject var textModel: EditableTextViewModel

    var body: some View {
        Group {
            if infoModel.reportSize {
                Color.clear.overlay(
                    content
                        .sizeReader { size in
                            infoModel.sizeChanged?(size)
                        },
                    alignment: .top
                )
            } else {
                content
            }
        }
        .edgesIgnoringSafeArea(.all)
    }

    var content: some View {
        let photo = model.slidesState?.currentPhoto ?? Photo(asset: PHAsset())

        let noteBinding: Binding<String> = Binding {
            let photo = model.slidesState?.currentPhoto ?? Photo(asset: PHAsset())
            let note = realmModel.container.getNote(from: photo.asset.localIdentifier)?.string ?? ""
            return note
        } set: { newValue in
            let note = PhotoMetadataNote(string: newValue)
            let photo = model.slidesState?.currentPhoto ?? Photo(asset: PHAsset())
            if let metadata = photo.metadata {
                realmModel.container.updatePhotoMetadata(metadata: metadata, text: nil, note: note)
            } else {
                let metadata = PhotoMetadata(assetIdentifier: photo.asset.localIdentifier)
                realmModel.container.updatePhotoMetadata(metadata: metadata, text: nil, note: note)
            }
            infoModel.noteChanged?()
        }

        return VStack(spacing: 0) {
            if infoModel.showHandle {
                Rectangle()
                    .fill(UIColor.secondaryLabel.color)
                    .frame(height: 0.4)
                    .opacity(0.75)

                Capsule()
                    .fill(UIColor.secondaryLabel.color)
                    .frame(width: 36, height: 5)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
                    .padding(.bottom, 4)
            }

            VStack(alignment: .leading) {
                Text(verbatim: "\(photo.asset.originalFilename ?? "Photo")")

                EditableTextView(model: textModel, text: noteBinding)
                    .overlay(
                        VStack {
                            if noteBinding.wrappedValue.isEmpty {
                                Text("Add a searchable note")
                                    .font(UIFont.preferredFont(forTextStyle: .body).font)
                                    .foregroundColor(.accent)
                                    .opacity(0.5)
                                    .padding(.vertical, 2)
                                    .padding(.leading, 6)
                            }
                        }
                        .allowsHitTesting(false),
                        alignment: .topLeading
                    )
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .overlay(
                        VStack {
                            if textModel.isEditing {
                                Button {
                                    textModel.endEditing?()
                                } label: {
                                    Image(systemName: "checkmark")
                                        .padding(14)
                                        .contentShape(Rectangle())
                                }
                                .transition(.scale)
                            }
                        }
                        .animation(.default, value: textModel.isEditing),

                        alignment: .topTrailing
                    )
                    .blueBackground()
                    .frame(height: PhotosSlidesConstants.notesHeight)

                Text(verbatim: "\(getDateString(from: photo))")
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .blueBackground()

                HStack {
                    let ignored = photo.isIgnored

                    if !ignored {
                        let (isScanned, scanTitle) = getScanState(from: photo)
                        PhotosScanningInfoButton(
                            title: scanTitle,
                            description: isScanned ? "Tap to Rescan" : nil,
                            isOn: isScanned
                        ) {
                            scanNow()
                        }
                        .transition(.scale(scale: 0.5).combined(with: .opacity))
                    }

                    PhotosScanningInfoButton(
                        title: ignored ? "Ignored" : "Ignore",
                        description: ignored ? "Tap to Unignore" : nil,
                        isOn: ignored
                    ) {
                        ignore(photo: photo)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)

                Group {
                    if let text = realmModel.container.getText(from: photo.asset.localIdentifier) {
                        if
                            photo.metadata?.dateScanned != nil,
                            !photo.isIgnored,
                            !Constants.versionsWithSlantedTextSupport.contains(text.scannedInVersion ?? "")
                        {
                            Button {
                                scanNow()
                            } label: {
                                Text("Rescan to support slanted text")
                            }
                        }
                    }
                }
                .foregroundColor(UIColor.secondaryLabel.color)
            }
            .foregroundColor(.accent)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(16)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    func scanNow() {
        guard let slidesPhoto = model.slidesState?.getCurrentSlidesPhoto() else { return }
        model.scanSlidesPhoto?(slidesPhoto)
    }

    func ignore(photo: Photo) {
        model.ignore(photos: [photo])
    }

    func getDateString(from photo: Photo) -> String {
        if let date = photo.asset.creationDate {
            return date.dateTimeFormat
        }
        return ""
    }

    /// 1. is scanned or not
    /// 2. title
    func getScanState(from photo: Photo) -> (Bool, String) {
        if let metadata = photo.metadata, metadata.dateScanned != nil {
            return (true, "Scanned")
        }
        return (false, "Scan Now")
    }
}

struct PhotosScanningInfoButton: View {
    let title: String
    var description: String?
    let isOn: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack {
                Text(title)

                if let description = description {
                    Text(description)
                        .font(.subheadline)
                }
            }
            .foregroundColor(isOn ? .white : .accent)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .blueBackground(highlighted: isOn)
        }
    }
}

extension Date {
    var dateTimeFormat: String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "MMM d, yyyy' at 'h:mm a"
        let string = formatter.string(from: self)
        return string
    }
}
