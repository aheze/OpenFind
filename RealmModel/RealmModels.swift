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
    @Persisted(primaryKey: true) var id = UUID()
    @Persisted var assetIdentifier = ""
    @Persisted var sentences = RealmSwift.List<RealmPhotoMetadataSentence>()
    @Persisted var isStarred = false
    @Persisted var dateCreated = Date()

    override init() {
        super.init()
    }

    init(
        id: UUID,
        assetIdentifier: String,
        sentences: RealmSwift.List<RealmPhotoMetadataSentence>,
        isStarred: Bool,
        dateCreated: Date
    ) {
        self.id = id
        self.assetIdentifier = assetIdentifier
        self.sentences = sentences
        self.isStarred = isStarred
        self.dateCreated = dateCreated
    }
    
    func getPhotoMetadata() -> PhotoMetadata {
        let metadata = PhotoMetadata(
            id: self.id,
            assetIdentifier: self.assetIdentifier,
            sentences: self.sentences.map { $0.getSentence() },
            isStarred: self.isStarred,
            dateCreated: self.dateCreated
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
    @Persisted var words = RealmSwift.List<String>()
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
