//
//  RealmModels.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/27/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit
import RealmSwift

class RealmPhotoMetadata: Object {
    @Persisted(primaryKey: true) var assetIdentifier = ""
    @Persisted var sentences: RealmSwift.List<RealmPhotoMetadataSentence>
    @Persisted var isScanned = false /// there could be no scan results, but still scanned
    @Persisted var isStarred = false

    override init() {
        super.init()
    }

    init(
        assetIdentifier: String,
        sentences: RealmSwift.List<RealmPhotoMetadataSentence>,
        isScanned: Bool,
        isStarred: Bool
    ) {
        self.assetIdentifier = assetIdentifier
        self.sentences = sentences
        self.isScanned = isScanned
        self.isStarred = isStarred
    }
    
    func getPhotoMetadata() -> PhotoMetadata {
        let metadata = PhotoMetadata(
            assetIdentifier: self.assetIdentifier,
            sentences: self.sentences.map { $0.getSentence() },
            isScanned: self.isScanned,
            isStarred: self.isStarred
        )
        return metadata
    }
    
}

class RealmPhotoMetadataSentence: Object {
    @Persisted var rect: RealmRect?
    @Persisted var string = ""
    
    func getSentence() -> Sentence {
        let rect = self.rect?.getRect() ?? .zero
        let sentence = Sentence(
            rect: rect,
            string: string
        )
        return sentence
    }
}

class RealmRect: Object {
    @Persisted var x = Double(0)
    @Persisted var y = Double(0)
    @Persisted var width = Double(0)
    @Persisted var height = Double(0)
    
    override init() {
        super.init()
    }
    
    init(
        x: Double,
        y: Double,
        width: Double,
        height: Double
    ) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
    
    func getRect() -> CGRect {
        let rect = CGRect(
            x: x,
            y: y,
            width: width,
            height: height
        )
        return rect
    }
}

class RealmList: Object {
    @Persisted(primaryKey: true) var id = UUID()
    @Persisted var name = ""
    @Persisted var desc = ""
    @Persisted var words: RealmSwift.List<String>
    @Persisted var icon = ""
    @Persisted var color = 0x00AEEF
    @Persisted var dateCreated = Date()

    override init() {
        super.init()
    }

    init(
        id: UUID,
        name: String,
        desc: String,
        words: RealmSwift.List<String>,
        icon: String,
        color: Int,
        dateCreated: Date
    ) {
        self.id = id
        self.name = name
        self.desc = desc
        self.words = words
        self.icon = icon
        self.color = color
        self.dateCreated = dateCreated
    }
}

class RealmWord: Object {
    @Persisted(primaryKey: true) var id = UUID()
    @Persisted var string = ""
}

class RealmHistory: Object {
    /// the date when it was searched for
    @Persisted var date = Date()

    /// word or list?
    @Persisted var valueType: RealmValueType
    @Persisted var word: RealmWord?
    @Persisted var list: RealmList?
}

enum RealmValueType: String, PersistableEnum {
    case word
    case list
}
