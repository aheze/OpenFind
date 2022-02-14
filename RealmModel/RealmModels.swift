//
//  RealmModels.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/27/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Foundation
import RealmSwift

class RealmPhoto: Object {
    @Persisted(primaryKey: true) var id = UUID()
    @Persisted var assetIdentifier = ""
    @Persisted var sentences = RealmSwift.List<RealmPhotoSentence>()
    @Persisted var isStarred = false
    @Persisted var dateCreated = Date()

    override init() {
        super.init()
    }

    init(
        id: UUID,
        assetIdentifier: String,
        sentences: RealmSwift.List<RealmPhotoSentence>,
        isStarred: Bool,
        dateCreated: Date
    ) {
        self.id = id
        self.assetIdentifier = assetIdentifier
        self.sentences = sentences
        self.isStarred = isStarred
        self.dateCreated = dateCreated
    }
}

class RealmPhotoSentence: Object {
    @Persisted var rect: RealmRect?
    @Persisted var string = ""
}

class RealmRect: Object {
    @Persisted var x = Double(0)
    @Persisted var y = Double(0)
    @Persisted var width = Double(0)
    @Persisted var height = Double(0)
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
