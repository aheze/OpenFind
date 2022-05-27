//
//  CameraVC+Snapshot.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Photos
import UIKit

extension CameraViewController {
    func snapshot() {
        /// only snapshot if the snapshot hasn't started saving yet
        if model.snapshotState == .inactive {
            if
                let image = model.pausedImage,
                image.cgImage != nil
            {
                model.setSnapshotState(to: .startedSaving)
                self.saveImage(image)
            } else {
                model.setSnapshotState(to: .noImageYet)
            }
        }
    }

    func saveImage(_ image: PausedImage) {
        photosPermissionsViewModel.$currentStatus
            .dropFirst()
            .sink { [weak self] status in
                guard let self = self else { return }
                if status.isGranted() {
                    self.saveImageAfterPermissionsGranted(image: image)
                } else {
                    self.model.setSnapshotState(to: .inactive)
                }
            }
            .store(in: &realmModel.cancellables)

        if photosPermissionsViewModel.currentStatus.isGranted() {
            self.saveImageAfterPermissionsGranted(image: image)
        } else if photosPermissionsViewModel.currentStatus == .notDetermined {
            let alert = UIAlertController(title: "Save Photo To Photo Library", message: "Find needs permission to save this photo to your photo library.", preferredStyle: .alert)
            alert.addAction(
                UIAlertAction(title: "Continue", style: .default) { [weak self] _ in
                    guard let self = self else { return }
                    self.photosPermissionsViewModel.requestAuthorization()
                }
            )
            alert.addAction(
                UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
                    guard let self = self else { return }
                    self.model.setSnapshotState(to: .inactive)
                }
            )

            if let popoverPresentationController = alert.popoverPresentationController {
                popoverPresentationController.sourceView = self.landscapeToolbarContainer
                popoverPresentationController.sourceRect = self.landscapeToolbarContainer.bounds
                popoverPresentationController.permittedArrowDirections = .right
            }
            present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Save Photo To Photo Library", message: "Find needs permission to save this photo to your photo library.", preferredStyle: .alert)
            alert.addAction(
                UIAlertAction(title: "Go To Settings", style: .default) { [weak self] _ in
                    guard let self = self else { return }
                    self.photosPermissionsViewModel.goToSettings()
                }
            )
            alert.addAction(
                UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
                    guard let self = self else { return }
                    self.model.setSnapshotState(to: .inactive)
                }
            )
            if let popoverPresentationController = alert.popoverPresentationController {
                popoverPresentationController.sourceView = self.landscapeToolbarContainer
                popoverPresentationController.sourceRect = self.landscapeToolbarContainer.bounds
                popoverPresentationController.permittedArrowDirections = .right
            }
            present(alert, animated: true, completion: nil)
        }
    }

    func saveImageAfterPermissionsGranted(image: PausedImage) {
        guard let cgImage = image.cgImage else { return }
        let uiImage = UIImage(cgImage: cgImage)
        guard let jpegData = uiImage.jpegData(compressionQuality: 1) else { return }

        var assetIdentifier: String?

        PHPhotoLibrary.shared().performChanges {
            let creationRequest = PHAssetCreationRequest.forAsset()
            creationRequest.addResource(with: .photo, data: jpegData, options: nil)
            assetIdentifier = creationRequest.placeholderForCreatedAsset?.localIdentifier
        } completionHandler: { success, _ in

            if
                success,
                let assetIdentifier = assetIdentifier
            {
                DispatchQueue.main.async {
                    let metadata: PhotoMetadata

                    guard let currentPausedImage = self.model.pausedImage else { return }
                    if currentPausedImage.id == image.id {
                        self.model.pausedImage?.assetIdentifier = assetIdentifier
                        self.model.setSnapshotState(to: .saved)

                        /// the photo may have been scanned before the closure was called. if so, save the sentences.
                        metadata = PhotoMetadata(
                            assetIdentifier: assetIdentifier,
                            isStarred: false,
                            isIgnored: false,
                            dateScanned: currentPausedImage.dateScanned
                        )

                        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: .none)
                        if let asset = assets.firstObject {
                            let photo = Photo(asset: asset, metadata: metadata)
                            self.model.photoAdded?(photo)
                            self.realmModel.container.updatePhotoMetadata(
                                metadata: metadata,
                                text: currentPausedImage.text,
                                note: nil
                            )
                            self.realmModel.incrementExperience(by: 3)
                        }
                    }
                }
            }
        }
    }
}
