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

                print("performinc mfiration!!!")
                if oldSchemaVersion == 17 {
                    var photoMetadatas = [PhotoMetadata]()
                    
                    migration.enumerateObjects(ofType: "RealmPhotoMetadata") { oldObject, newObject in

                        print("phto..")
                        guard let oldObject = oldObject else { return }
                        
                        let text = RealmPhotoMetadataText()
                        text.scannedInVersion = nil
                        
                        
                        if let scannedInLanguages = oldObject["scannedInLanguages"] as? RealmSwift.List<String> {
                            print("scannedInLanguages: \(scannedInLanguages)")
                            text.scannedInLanguages = scannedInLanguages
                        }
                        
                        if let sentences = oldObject["sentences"] as? RealmSwift.List<DynamicObject> {
                            print("Got sentences. \(sentences.count)")
                            for sentence in sentences {
                                let newSentence = RealmSentence()
                                
                                if let string = sentence["string"] as? String {
                                    newSentence.string = string
                                    print("Got string. \(string)")
                                }
                                
                                if let confidence = sentence["confidence"] as? Double {
                                    newSentence.confidence = confidence
                                    print("Got confidence. \(confidence)")
                                }
                                
                                if let components = sentence["components"] as? RealmSwift.List<DynamicObject> {
                                    print("Got components. \(components)")
                                    if let firstComponent = components.first {
                                        if let frame = firstComponent["frame"] as? DynamicObject {
                                            print("Got first frame. \(frame)")
                                            var rect = CGRect.zero
                                            if let x = frame["x"] as? Double { rect.origin.x = x }
                                            if let y = frame["y"] as? Double { rect.origin.y = y }
                                            if let width = frame["width"] as? Double { rect.size.width = width }
                                            if let height = frame["height"] as? Double { rect.size.height = height }
                                            
                                            
                                            print("-> FIRST rect becomes \(rect)")
                                            newSentence.topLeft = RealmPoint(x: rect.minX, y: rect.minY)
                                            newSentence.bottomLeft = RealmPoint(x: rect.minX, y: rect.maxY)
                                        }
                                    }
                                    
                                    if let lastComponent = components.last {
                                        if let frame = lastComponent["frame"] as? DynamicObject {
                                            print("Got last frame. \(frame)")
                                            var rect = CGRect.zero
                                            if let x = frame["x"] as? Double { rect.origin.x = x }
                                            if let y = frame["y"] as? Double { rect.origin.y = y }
                                            if let width = frame["width"] as? Double { rect.size.width = width }
                                            if let height = frame["height"] as? Double { rect.size.height = height }
                                         
                                            
                                            print("-> LAST rect becomes \(rect)")
                                            newSentence.topRight = RealmPoint(x: rect.maxX, y: rect.minY)
                                            newSentence.bottomRight = RealmPoint(x: rect.maxX, y: rect.maxY)
                                        }
                                    }
                                }
                                
                                text.sentences.append(newSentence)
                            }
                        }
                        
                        
                        print("Setting. \(text)")
                        newObject?["text"] = text
                        
                        
                        
//                        class RealmSentenceComponent: Object {
//                            @Persisted var range: RealmIntRange?
//                            @Persisted var frame: RealmRect?
//                        }
//
//                        class RealmIntRange: Object {
//                            @Persisted var lowerBound = 0
//                            @Persisted var upperBound = 0
                        
//                        class RealmRect: Object {
//                            @Persisted var x = Double(0)
//                            @Persisted var y = Double(0)
//                            @Persisted var width = Double(0)
//                            @Persisted var height = Double(0)

//                        class RealmPhotoMetadataText: Object {
//                            @Persisted var sentences: RealmSwift.List<RealmSentence>
//                            @Persisted var scannedInLanguages: RealmSwift.List<String> /// which languages scanned in
//                            @Persisted var scannedInVersion: String?
                        
//                        class RealmPhotoMetadata: Object {
//                            @Persisted(primaryKey: true) var assetIdentifier = ""
//                            @Persisted var dateScanned: Date? /// there could be no scan results, but still scanned
//                            @Persisted var sentences: RealmSwift.List<RealmSentence> /// scan results
//                            @Persisted var scannedInLanguages: RealmSwift.List<String> /// which languages scanned in
//                            @Persisted var isStarred = false
//                            @Persisted var isIgnored = false
     
//                        class RealmSentence: Object {
//                            @Persisted var string: String?
//                            @Persisted var components: RealmSwift.List<RealmSentenceComponent>
//                            @Persisted var confidence: Double?

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
