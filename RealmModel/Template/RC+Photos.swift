//
//  RC+Photos.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/31/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension RealmModel {
    /// get the photo metadata of an photo if it exists
    func getPhotoMetadata(from identifier: String) -> PhotoMetadata? {
        if let photoMetadata = photoMetadatas.first(where: { $0.assetIdentifier == identifier }) {
            return photoMetadata
        }
        return nil
    }

    /// handles both add or update
    /// Make sure to transfer any properties from `PhotoMetadata` to `RealmPhotoMetadata`
    func updatePhotoMetadata(metadata: PhotoMetadata?) {
        guard let metadata = metadata else {
            Debug.log("No metadata.")
            return
        }
        if let firstIndex = photoMetadatas.firstIndex(where: { $0.assetIdentifier == metadata.assetIdentifier }) {
            photoMetadatas[firstIndex] = metadata
        } else {
            addPhotoMetadata(metadata: metadata)
        }
    }

    func deletePhotoMetadata(metadata: PhotoMetadata) {
        if let firstIndex = photoMetadatas.firstIndex(where: { $0.assetIdentifier == metadata.assetIdentifier }) {
            photoMetadatas.remove(at: firstIndex)
        }
    }

    /// call this inside `updatePhotoMetadata`
    private func addPhotoMetadata(metadata: PhotoMetadata) {
        photoMetadatas.append(metadata)
    }
}
