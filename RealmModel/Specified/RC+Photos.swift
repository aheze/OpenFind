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
        DispatchQueue.main.async {
            self.photoMetadatasUpdated?(photoMetadatas)
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
            print("extists!")
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
            print("add instead.")
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
        print("adding. \(metadata)")
        let realmSentences = metadata.getRealmSentences()
        print("realmSentences. \(realmSentences)")
        let scannedInLanguages = metadata.getRealmScannedInLanguages()
        print("scannedInLanguages. \(scannedInLanguages)")
        
        let realmMetadata = RealmPhotoMetadata(
            assetIdentifier: metadata.assetIdentifier,
            dateScanned: metadata.dateScanned,
            sentences: realmSentences,
            scannedInLanguages: scannedInLanguages,
            isStarred: metadata.isStarred,
            isIgnored: metadata.isIgnored
        )
        print("created.")

        do {
            try realm.write {
                realm.add(realmMetadata)
                print("added.")
            }
        } catch {
            Debug.log("Error adding photo metadata: \(error)", .error)
        }
    }
}
