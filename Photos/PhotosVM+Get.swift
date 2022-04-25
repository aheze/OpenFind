//
//  PhotosC+Get.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/25/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Photos
import UIKit

extension PhotosViewModel {
    /// get from `photos`
    func getIndex(for photo: Photo, in keyPath: KeyPath<PhotosViewModel, [Photo]>) -> Int? {
        let photos = self[keyPath: keyPath]
        if let firstIndex = photos.firstIndex(of: photo) {
            return firstIndex
        }
        return nil
    }

    /// get from `displayedSections` or some other section array
    func getIndexPath(for photo: Photo, in keyPath: KeyPath<PhotosViewModel, [PhotosSection]>) -> IndexPath? {
        let sections = self[keyPath: keyPath]
        for sectionIndex in sections.indices {
            if let photoIndex = sections[sectionIndex].photos.firstIndex(of: photo) {
                return IndexPath(item: photoIndex, section: sectionIndex)
            }
        }
        return nil
    }

    /// get from `sections`
    func getPhoto(from metadata: PhotoMetadata) -> Photo? {
        let photo = photos.first { $0.asset.localIdentifier == metadata.assetIdentifier }
        return photo
    }

    func getFullImage(from asset: PHAsset) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            options.progressHandler = { [weak self] progress, error, _, _ in
                guard let self = self else { return }
                self.addNote(.downloadingFromCloud)
            }
            imageManager.requestImage(
                for: asset,
                targetSize: .zero,
                contentMode: .aspectFit,
                options: options
            ) { image, info in
                continuation.resume(returning: image)
            }
        }
    }

    func getSmallImage(from asset: PHAsset, targetSize: CGSize, contentMode: PHImageContentMode = .aspectFill, completion: ((UIImage?) -> Void)?) {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        self.imageManager.requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: options
        ) { thumbnail, _ in
            completion?(thumbnail)
        }
    }
}
