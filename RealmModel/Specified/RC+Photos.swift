//
//  RC+Photos.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/28/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import RealmSwift
import UIKit

extension RealmContainer {
    func loadPhotoMetadatas() {
        var photoMetadatas = [PhotoMetadata]()

        /// convert realm lists to normal lists
        let realmPhotoMetadatas = realm.objects(RealmPhotoMetadata.self)
        for realmPhotoMetadata in realmPhotoMetadatas {
            let metadata = realmPhotoMetadata.getPhotoMetadata()
            photoMetadatas.append(metadata)
        }

        self.photoMetadatas = photoMetadatas
    }
    
    func deleteAllMetadata() {
        let metadatas = realm.objects(RealmPhotoMetadata.self)

        do {
            try realm.write {
                realm.delete(metadatas)
            }
        } catch {
            Debug.log("Error deleting all metadata: \(error)", .error)
        }
    }

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
        if let realmMetadata = realm.object(ofType: RealmPhotoMetadata.self, forPrimaryKey: metadata.assetIdentifier) {
            let realmSentences = metadata.getRealmSentences()
            do {
                try realm.write {
                    realmMetadata.dateScanned = metadata.dateScanned
                    realmMetadata.sentences = realmSentences
                    realmMetadata.isStarred = metadata.isStarred
                    realmMetadata.isIgnored = metadata.isIgnored
                }
            } catch {
                Debug.log("Error updating photo metadata: \(error)", .error)
            }
        } else {
            addPhotoMetadata(metadata: metadata)
        }
    }

    func deletePhotoMetadata(metadata: PhotoMetadata) {
        if let realmMetadata = realm.object(ofType: RealmPhotoMetadata.self, forPrimaryKey: metadata.assetIdentifier) {
            do {
                try realm.write {
                    realm.delete(realmMetadata)
                }
            } catch {
                Debug.log("Error deleting metadata: \(error)", .error)
            }
        }
    }

    /// call this inside `updatePhotoMetadata`
    private func addPhotoMetadata(metadata: PhotoMetadata) {
        let realmSentences = metadata.getRealmSentences()
        let realmMetadata = RealmPhotoMetadata(
            assetIdentifier: metadata.assetIdentifier,
            sentences: realmSentences,
            dateScanned: metadata.dateScanned,
            isStarred: metadata.isStarred,
            isIgnored: metadata.isIgnored
        )

        do {
            try realm.write {
                realm.add(realmMetadata)
            }
        } catch {
            Debug.log("Error adding photo metadata: \(error)", .error)
        }
    }
}
