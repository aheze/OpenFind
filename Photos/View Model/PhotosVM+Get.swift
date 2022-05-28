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

    func getPhoto(from indexPath: IndexPath) -> Photo? {
        let photo = displayedSections[safe: indexPath.section]?.photos[safe: indexPath.row]
        return photo
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

                if let error = error {
                    self.addNote(.photosFailedToScan(error: error.localizedDescription))
                }
            }
            imageManager.requestImage(
                for: asset,
                targetSize: .zero,
                contentMode: .aspectFit,
                options: options
            ) { image, info in
                if let error = info?[PHImageErrorKey] as? Error {
                    self.addNote(.photosFailedToScan(error: error.localizedDescription))
                }

                if let image = image, image.size == .zero {
                    self.addNote(.photosFailedToScan(error: "Some photos weren't downloaded completely."))
                }
                continuation.resume(returning: image)
            }
        }
    }

    func getImage(
        from asset: PHAsset,
        targetSize: CGSize,
        contentMode: PHImageContentMode = .aspectFill,
        options defaultOptions: PHImageRequestOptions? = nil,
        completion: ((UIImage?) -> Void)?
    ) -> PHImageRequestID {
        let options: PHImageRequestOptions = defaultOptions ?? {
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            options.resizeMode = .fast
            options.deliveryMode = .fastFormat
            return options
        }()

        return imageManager.requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: options
        ) { image, _ in
            completion?(image)
        }
    }

    /// closure-based for returning multiple times
    func getFullImage(from asset: PHAsset, completion: @escaping ((UIImage?) -> Void)) {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        
        _ = getImage(
            from: asset,
            targetSize: .zero,
            options: options,
            completion: completion
        )
    }
}
