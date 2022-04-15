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
    @Persisted var dateScanned: Date? /// there could be no scan results, but still scanned
    @Persisted var sentences: RealmSwift.List<RealmSentence> /// scan results
    @Persisted var scannedInLanguages: RealmSwift.List<String> /// which languages scanned in
    @Persisted var isStarred = false
    @Persisted var isIgnored = false

    override init() {
        super.init()
    }

    init(
        assetIdentifier: String,
        dateScanned: Date?,
        sentences: RealmSwift.List<RealmSentence>,
        scannedInLanguages: RealmSwift.List<String>,
        isStarred: Bool,
        isIgnored: Bool
    ) {
        self.assetIdentifier = assetIdentifier
        self.dateScanned = dateScanned
        self.sentences = sentences
        self.scannedInLanguages = scannedInLanguages
        self.isStarred = isStarred
        self.isIgnored = isIgnored
    }

    func getPhotoMetadata() -> PhotoMetadata {
        let metadata = PhotoMetadata(
            assetIdentifier: self.assetIdentifier,
            dateScanned: self.dateScanned,
            sentences: self.sentences.map { $0.getSentence() },
            scannedInLanguages: self.scannedInLanguages.map { $0 },
            isStarred: self.isStarred,
            isIgnored: self.isIgnored
        )
        return metadata
    }
}

class RealmSentence: Object {
    @Persisted var string: String?
    @Persisted var components: RealmSwift.List<RealmSentenceComponent>
    @Persisted var confidence: Double?

    func getSentence() -> Sentence {
        let components = self.components.map {
            Sentence.Component(
                range: $0.range?.getRange() ?? 0 ..< 1,
                frame: $0.frame?.getRect() ?? .zero
            )
        }

        return Sentence(
            string: self.string ?? "",
            components: Array(components),
            confidence: self.confidence ?? 0
        )
    }
}

class RealmSentenceComponent: Object {
    @Persisted var range: RealmIntRange?
    @Persisted var frame: RealmRect?
}

class RealmIntRange: Object {
    @Persisted var lowerBound = 0
    @Persisted var upperBound = 0

    override init() {
        super.init()
    }

    init(lowerBound: Int, upperBound: Int) {
        self.lowerBound = lowerBound
        self.upperBound = upperBound
    }

    func getRange() -> Range<Int> {
        return self.lowerBound ..< self.upperBound
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
