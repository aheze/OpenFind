//
//  CameraVC+Static.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/31/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//

import Photos
import UIKit

/**
 When the camera view controller is paused
 */

extension CameraViewController {
    func resume() {
        AppDelegate.AppUtility.lockOrientation(.all)
        model.pausedImage = nil
        focusGestureRecognizer.isEnabled = true
        livePreviewViewController?.livePreviewView.videoPreviewLayer.connection?.isEnabled = true
        endAutoProgress()
        removeScrollZoomImage()
        showLivePreview()
        showZoomView()
    }

    func pause() {
        focusGestureRecognizer.isEnabled = false
        guard let livePreviewViewController = livePreviewViewController else { return }

        Task {
            let currentOrientation = UIWindow.currentInterfaceOrientation
            AppDelegate.AppUtility.lockOrientation(currentOrientation?.getMask() ?? .all)
            let pausedImage = PausedImage(orientationTakenIn: currentOrientation)

            let currentUUID = pausedImage.id

            await MainActor.run {
                model.pausedImage = pausedImage
                livePreviewViewController.livePreviewView.videoPreviewLayer.connection?.isEnabled = false
                startAutoProgress()
                hideZoomView()
            }

            let image = await livePreviewViewController.takePhoto()

            guard currentUUID == self.model.pausedImage?.id else { return }
            self.setScrollZoomImage(image: image)

            if let cgImage = image.cgImage {
                /// set the image
                self.model.pausedImage?.cgImage = cgImage
                if model.snapshotState == .noImageYet, let pausedImage = self.model.pausedImage {
                    saveImage(pausedImage)
                }

                await scan(currentUUID: currentUUID, cgImage: cgImage)

                guard currentUUID == self.model.pausedImage?.id else { return }
                self.endAutoProgress()
                self.hideLivePreview()
            }
        }
    }

    /// currentUUID is the id of the image to scan from
    func scan(currentUUID: UUID, cgImage: CGImage) async {
        Find.prioritizedAction = .camera
        let sentences = await self.findAndAddHighlights(image: cgImage, wait: true)
        let currentDate = Date()
        let scannedInLanguages = realmModel.getCurrentRecognitionLanguages(accurateMode: true)
        guard currentUUID == self.model.pausedImage?.id else { return }

        await MainActor.run {
            /// set the sentences
            self.model.pausedImage?.sentences = sentences
            self.model.pausedImage?.dateScanned = currentDate
            self.model.pausedImage?.scannedInLanguages = scannedInLanguages
        }

        /// photo was saved to the photo library. Update the sentences

        if let assetIdentifier = self.model.pausedImage?.assetIdentifier {
            let metadata = PhotoMetadata(
                assetIdentifier: assetIdentifier,
                dateScanned: currentDate,
                sentences: sentences,
                scannedInLanguages: scannedInLanguages,
                isStarred: false,
                isIgnored: false
            )
            DispatchQueue.main.async {
                let assets = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: .none)
                if let asset = assets.firstObject {
                    let photo = Photo(asset: asset, metadata: metadata)
                    self.model.photoAdded?(photo)
                    self.realmModel.container.updatePhotoMetadata(metadata: metadata)
                }
            }
        }
        Find.prioritizedAction = nil /// paused now, do whatever
    }
}
