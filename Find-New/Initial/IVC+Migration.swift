//
//  IVC+Migration.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/29/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import RealmSwift
import UIKit

extension InitialViewController {
    /// 18 = 2.0.4
    /// 17 = 2.0.0
    func configureRealm() {
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 18,

            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { [weak self] migration, oldSchemaVersion in
                guard let self = self else { return }

                var migratedPhotoMetadatas = [PhotoMetadata]()
                var migratedLists = [List]()

                if oldSchemaVersion == 17 {
                    migration.enumerateObjects(ofType: "RealmPhotoMetadata") { oldObject, newObject in

                        guard let oldObject = oldObject else { return }

                        let text = RealmPhotoMetadataText()
                        text.scannedInVersion = nil

                        if let scannedInLanguages = oldObject["scannedInLanguages"] as? RealmSwift.List<String> {
                            text.scannedInLanguages = scannedInLanguages
                        }

                        if let sentences = oldObject["sentences"] as? RealmSwift.List<DynamicObject> {
                            for sentence in sentences {
                                let newSentence = RealmSentence()

                                if let string = sentence["string"] as? String {
                                    newSentence.string = string
                                }

                                if let confidence = sentence["confidence"] as? Double {
                                    newSentence.confidence = confidence
                                }

                                /// convert components to `topLeft`, `topRight`, `bottomRight`, `bottomLeft`
                                if let components = sentence["components"] as? RealmSwift.List<DynamicObject> {
                                    if let firstComponent = components.first {
                                        if let frame = firstComponent["frame"] as? DynamicObject {
                                            var rect = CGRect.zero
                                            if let x = frame["x"] as? Double { rect.origin.x = x }
                                            if let y = frame["y"] as? Double { rect.origin.y = y }
                                            if let width = frame["width"] as? Double { rect.size.width = width }
                                            if let height = frame["height"] as? Double { rect.size.height = height }

                                            newSentence.topLeft = RealmPoint(x: rect.minX, y: rect.minY)
                                            newSentence.bottomLeft = RealmPoint(x: rect.minX, y: rect.maxY)
                                        }
                                    }

                                    if let lastComponent = components.last {
                                        if let frame = lastComponent["frame"] as? DynamicObject {
                                            var rect = CGRect.zero
                                            if let x = frame["x"] as? Double { rect.origin.x = x }
                                            if let y = frame["y"] as? Double { rect.origin.y = y }
                                            if let width = frame["width"] as? Double { rect.size.width = width }
                                            if let height = frame["height"] as? Double { rect.size.height = height }

                                            newSentence.topRight = RealmPoint(x: rect.maxX, y: rect.minY)
                                            newSentence.bottomRight = RealmPoint(x: rect.maxX, y: rect.maxY)
                                        }
                                    }
                                }

                                text.sentences.append(newSentence)
                            }
                        }

                        newObject?["text"] = text
                    }
                }

                /// Find v1.2
                if oldSchemaVersion == 16 {
                    var photoMetadatas = [PhotoMetadata]()
                    migration.enumerateObjects(ofType: "HistoryModel") { oldObject, _ in

                        guard let oldObject = oldObject else { return }

                        var photoMetadata = PhotoMetadata()

                        if let assetIdentifier = oldObject["assetIdentifier"] as? String {
                            photoMetadata.assetIdentifier = assetIdentifier
                        }

                        if let isHearted = oldObject["isHearted"] as? Bool, isHearted {
                            photoMetadata.isStarred = isHearted
                        }
                        photoMetadatas.append(photoMetadata)
                    }

                    var lists = [List]()
                    migration.enumerateObjects(ofType: "FindList") { oldObject, _ in
                        guard let oldObject = oldObject else { return }

                        var list = List()
                        if let name = oldObject["name"] as? String {
                            list.title = name
                        }

                        if let descriptionOfList = oldObject["descriptionOfList"] as? String {
                            list.description = descriptionOfList
                        }

                        if let iconImageName = oldObject["iconImageName"] as? String {
                            list.icon = iconImageName
                        }

                        if let iconColorName = oldObject["iconColorName"] as? String {
                            let color = UIColor(hexString: iconColorName)
                            if let hex = color.getHex() {
                                list.color = hex
                            }
                        }
                        if let contents = oldObject["contents"] as? RealmSwift.List<String> {
                            list.words = contents.map { $0 }
                        }
                        lists.append(list)
                    }

                    migratedPhotoMetadatas = photoMetadatas
                    migratedLists = lists

                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }

                if !migratedPhotoMetadatas.isEmpty || !migratedLists.isEmpty {
                    DispatchQueue.main.async {
                        for metadata in migratedPhotoMetadatas {
                            self.realmModel.container.updatePhotoMetadata(metadata: metadata, text: nil)
                        }

                        for list in migratedLists {
                            self.realmModel.container.addList(list: list)
                        }
                    }
                }
            }
        )

        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
    }
}
