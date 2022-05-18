//
//  RealmModels.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/27/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import RealmSwift
import UIKit

class RealmPhotoMetadata: Object {
    @Persisted(primaryKey: true) var assetIdentifier = ""
    @Persisted var isStarred = false
    @Persisted var isIgnored = false
    @Persisted var dateScanned: Date?
    @Persisted var text: RealmPhotoMetadataText?

    override init() {
        super.init()
    }

    init(
        assetIdentifier: String,
        isStarred: Bool,
        isIgnored: Bool,
        dateScanned: Date?,
        text: RealmPhotoMetadataText?
    ) {
        self.assetIdentifier = assetIdentifier
        self.text = text
        self.isStarred = isStarred
        self.isIgnored = isIgnored
        self.dateScanned = dateScanned
    }

    func getPhotoMetadata() -> PhotoMetadata {
        let metadata = PhotoMetadata(
            assetIdentifier: self.assetIdentifier,
            isStarred: self.isStarred,
            isIgnored: self.isIgnored,
            dateScanned: self.dateScanned
        )
        return metadata
    }
}

class RealmPhotoMetadataText: Object {
    @Persisted var sentences: RealmSwift.List<RealmSentence>
    @Persisted var scannedInLanguages: RealmSwift.List<String> /// which languages scanned in
    @Persisted var scannedInVersion: String?

    func getPhotoMetadataText() -> PhotoMetadataText {
        let metadataText = PhotoMetadataText(
            sentences: sentences.map { $0.getSentence() },
            scannedInLanguages: self.scannedInLanguages.map { $0 },
            scannedInVersion: self.scannedInVersion
        )
        return metadataText
    }
}

class RealmSentence: Object {
    @Persisted var string: String?

    @Persisted var confidence: Double?

    /// normalized points from `0` to `1`
    @Persisted var topLeft: RealmPoint?
    @Persisted var topRight: RealmPoint?
    @Persisted var bottomRight: RealmPoint?
    @Persisted var bottomLeft: RealmPoint?

    func getSentence() -> Sentence {
        let sentence = Sentence(
            string: string ?? "",
            confidence: confidence ?? 0,
            topLeft: self.topLeft?.getCGPoint() ?? .zero,
            topRight: self.topRight?.getCGPoint() ?? .zero,
            bottomRight: self.bottomRight?.getCGPoint() ?? .zero,
            bottomLeft: self.bottomLeft?.getCGPoint() ?? .zero
        )

        return sentence
    }
}

class RealmPoint: Object {
    @Persisted var x: Double
    @Persisted var y: Double

    override init() {
        super.init()
    }

    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }

    func getCGPoint() -> CGPoint {
        let point = CGPoint(x: x, y: y)
        return point
    }
}

class RealmList: Object {
    @Persisted(primaryKey: true) var id: UUID
    @Persisted var title = ""
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
        title: String,
        desc: String,
        words: RealmSwift.List<String>,
        icon: String,
        color: Int,
        dateCreated: Date
    ) {
        super.init()
        self.id = id
        self.title = title
        self.desc = desc
        self.words = words
        self.icon = icon
        self.color = color
        self.dateCreated = dateCreated
    }
}

class RealmWord: Object {
    @Persisted(primaryKey: true) var id: UUID
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
