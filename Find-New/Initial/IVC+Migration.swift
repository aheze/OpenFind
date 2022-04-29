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
    func configureRealm() {
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 17,

            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { [weak self] migration, oldSchemaVersion in

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

                    if let self = self {
                        self.properties.migratedPhotoMetadatas = photoMetadatas
                        self.properties.migratedLists = lists
                    }
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
            }
        )

        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config

        DispatchQueue.main.async {
            self.loadMigratedData()
        }
    }

    // MARK: - Migration

    func loadMigratedData() {
        for metadata in properties.migratedPhotoMetadatas {
            self.realmModel.container.updatePhotoMetadata(metadata: metadata, text: nil)
        }

        for list in properties.migratedLists {
            self.realmModel.container.addList(list: list)
        }
    }
}
