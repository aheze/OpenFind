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
        let array = Array(photoMetadatas)
        applyPhotoMetadatas(array)
    }

    func applyPhotoMetadatas(_ photoMetadatas: [PhotoMetadata]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let model = self.getModel?() {
                model.photoMetadatas = photoMetadatas
            }
        }
    }

    func deleteAllScannedData() {
        let metadatas = realm.objects(RealmPhotoMetadata.self)

        do {
            try realm.write {
                for metadata in metadatas {
                    metadata.dateScanned = nil
                    metadata.sentences = RealmSwift.List<RealmSentence>()
                    metadata.scannedInLanguages = RealmSwift.List<String>()
                }
            }
            if let model = self.getModel?() {
                model.photoMetadatas.removeAll()
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
            let realmSentences = metadata.getRealmSentences()
            do {
                try realm.write {
                    realmMetadata.dateScanned = metadata.dateScanned
                    realmMetadata.sentences = realmSentences
                    realmMetadata.isStarred = metadata.isStarred
                    realmMetadata.isIgnored = metadata.isIgnored
                }

                if let model = getModel?() {
                    if let firstIndex = model.photoMetadatas.firstIndex(where: { $0.assetIdentifier == metadata.assetIdentifier }) {
                        model.photoMetadatas[firstIndex] = metadata
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
                    model.photoMetadatas = model.photoMetadatas.filter { $0.assetIdentifier != metadata.assetIdentifier }
                }
            } catch {
                Debug.log("Error deleting metadata: \(error)", .error)
            }
        }
    }

    /// call this inside `updatePhotoMetadata`
    private func addPhotoMetadata(metadata: PhotoMetadata) {
        let realmSentences = metadata.getRealmSentences()

        let scannedInLanguages = metadata.getRealmScannedInLanguages()

        let realmMetadata = RealmPhotoMetadata(
            assetIdentifier: metadata.assetIdentifier,
            dateScanned: metadata.dateScanned,
            sentences: realmSentences,
            scannedInLanguages: scannedInLanguages,
            isStarred: metadata.isStarred,
            isIgnored: metadata.isIgnored
        )

        do {
            try realm.write {
                realm.add(realmMetadata)
            }

            getModel?()?.photoMetadatas.append(metadata)
        } catch {
            Debug.log("Error adding photo metadata: \(error)", .error)
        }
    }
}
