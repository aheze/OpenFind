//
//  PhotosC+Get.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/25/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit
import Photos

extension PhotosViewModel {
    /// get from `photos`
    func getIndex(for photo: Photo, in keyPath: KeyPath<PhotosViewModel, Array<Photo>>) -> Int? {
        let photos = self[keyPath: keyPath]
        if let firstIndex = photos.firstIndex(of: photo) {
            return firstIndex
        }
        return nil
    }

    /// get from `displayedSections` or some other section array
    func getIndexPath(for photo: Photo, in keyPath: KeyPath<PhotosViewModel, Array<PhotosSection>>) -> IndexPath? {
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

    func getFullImage(from photo: Photo) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            imageManager.requestImage(
                for: photo.asset,
                targetSize: .zero,
                contentMode: .aspectFit,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }

    /// closure-based for immediate return
    func getFullImage(from photo: Photo, completion: @escaping ((UIImage?) -> Void)) {
        imageManager.requestImage(
            for: photo.asset,
            targetSize: .zero,
            contentMode: .aspectFit,
            options: nil
        ) { image, _ in
            completion(image)
        }
    }
}
