//
//  RealmModel+Photos.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/28/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

extension RealmModel {
    func loadPhotoMetadatas() {
        var photoMetadatas = [PhotoMetadata]()

        /// convert realm lists to normal lists
        let realmPhotoMetadatas = realm.objects(RealmPhotoMetadata.self)
        for realmPhotoMetadata in realmPhotoMetadatas {
            let metadata = realmPhotoMetadata.getPhotoMetadata()
            photoMetadatas.append(metadata)
        }
        self.photoMetadatas = photoMetadatas
        photoMetadatasUpdated()
    }
    
    /// get the photo metadata of an photo if it exists
    func getPhotoMetadata(from identifier: String) -> PhotoMetadata? {
        if let photoMetadata = photoMetadatas.first(where: { $0.assetIdentifier == identifier }) {
            return photoMetadata
        }
        return nil
    }
}
