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
    /// this function takes a while to run, add `await`
    func loadPhotoMetadatas() {
        let realm = try! Realm()
        /// convert realm lists to normal lists
        let realmPhotoMetadatas = realm.objects(RealmPhotoMetadata.self)

        /// this line is very fast actually
        let photoMetadatas = realmPhotoMetadatas.map {
            $0.getPhotoMetadata()
        }

        DispatchQueue.main.async {
            if let model = self.getModel?() {
                let assetIdentifierToPhotoMetadata = photoMetadatas.reduce(into: [String: PhotoMetadata]()) {
                    $0[$1.assetIdentifier] = $1
                }

                model.assetIdentifierToPhotoMetadata = assetIdentifierToPhotoMetadata
            }
        }
    }

    func deleteAllScannedData() {
        let metadatas = realm.objects(RealmPhotoMetadata.self)

        do {
            try realm.write {
                for metadata in metadatas {
                    metadata.dateScanned = nil
                    metadata.text?.sentences = RealmSwift.List<RealmSentence>()
                    metadata.text?.scannedInLanguages = RealmSwift.List<String>()
                }
            }
            if let model = getModel?() {
                model.assetIdentifierToPhotoMetadata.removeAll()
            }
        } catch {
            Debug.log("Error deleting all scanned data: \(error)", .error)
        }
    }

    /// handles both add or update
    /// Make sure to transfer any properties from `PhotoMetadata` to `RealmPhotoMetadata`
    func updatePhotoMetadata(metadata: PhotoMetadata?) {
        guard let metadata = metadata else {
            Debug.log("No metadata.")
            return
        }

        if let realmMetadata = realm.object(ofType: RealmPhotoMetadata.self, forPrimaryKey: metadata.assetIdentifier) {
            let text = metadata.text?.getRealmText()
            do {
                try realm.write {
                    realmMetadata.isStarred = metadata.isStarred
                    realmMetadata.isIgnored = metadata.isIgnored
                    realmMetadata.dateScanned = metadata.dateScanned
                    realmMetadata.text = text
                }

                if let model = getModel?() {
                    if model.assetIdentifierToPhotoMetadata[metadata.assetIdentifier] != nil {
                        model.assetIdentifierToPhotoMetadata[metadata.assetIdentifier] = metadata
                    }
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

                if let model = getModel?() {
                    model.assetIdentifierToPhotoMetadata[metadata.assetIdentifier] = nil
                    
                }
            } catch {
                Debug.log("Error deleting metadata: \(error)", .error)
            }
        }
    }

    /// call this inside `updatePhotoMetadata`
    private func addPhotoMetadata(metadata: PhotoMetadata) {
        let text = metadata.text?.getRealmText()

        let realmMetadata = RealmPhotoMetadata(
            assetIdentifier: metadata.assetIdentifier,
            isStarred: metadata.isStarred,
            isIgnored: metadata.isIgnored,
            dateScanned: metadata.dateScanned,
            text: text
        )

        do {
            try realm.write {
                realm.add(realmMetadata)
            }

            getModel?()?.assetIdentifierToPhotoMetadata[metadata.assetIdentifier] = metadata
        } catch {
            Debug.log("Error adding photo metadata: \(error)", .error)
        }
    }
}
