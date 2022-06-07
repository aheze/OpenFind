//
//  RealmModelSpecifiedExtensions.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 5/13/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import RealmSwift
import UIKit

extension PhotoMetadataText {
    func getRealmText() -> RealmPhotoMetadataText {
        let text = RealmPhotoMetadataText()
        text.sentences = self.getRealmSentences()
        text.scannedInLanguages = self.getRealmScannedInLanguages()
        text.scannedInVersion = scannedInVersion
        return text
    }

    func getRealmSentences() -> RealmSwift.List<RealmSentence> {
        let realmSentences = RealmSwift.List<RealmSentence>()
        for sentence in self.sentences {
            let realmSentence = sentence.getRealmSentence()
            realmSentences.append(realmSentence)
        }
        return realmSentences
    }

    func getRealmScannedInLanguages() -> RealmSwift.List<String> {
        let realmScannedInLanguages = RealmSwift.List<String>()
        for scannedInLanguage in self.scannedInLanguages {
            realmScannedInLanguages.append(scannedInLanguage)
        }
        return realmScannedInLanguages
    }
}

extension PhotoMetadataText {
    static var sampleSentence = Sentence(
        string: "Hello, this is some testing test AAAAA",
        confidence: 1,
        topLeft: .init(x: 0, y: 0),
        topRight: .init(x: 1, y: 0),
        bottomRight: .init(x: 1, y: 1),
        bottomLeft: .init(x: 0, y: 1)
    )
    static var sampleText = PhotoMetadataText(
        sentences: Array(repeating: sampleSentence, count: 10),
        scannedInLanguages: ["en_US"],
        scannedInVersion: "2.0.7"
    )
    static var sampleRealmText = sampleText.getRealmText()
}

extension PhotoMetadataNote {
    func getRealmNote() -> RealmPhotoMetadataNote {
        let note = RealmPhotoMetadataNote()
        note.string = string
        return note
    }
}

extension Sentence {
    func getRealmSentence() -> RealmSentence {
        let realmSentence = RealmSentence()
        realmSentence.string = string
        realmSentence.confidence = confidence
        realmSentence.topLeft = self.topLeft.getRealmPoint()
        realmSentence.topRight = self.topRight.getRealmPoint()
        realmSentence.bottomRight = self.bottomRight.getRealmPoint()
        realmSentence.bottomLeft = self.bottomLeft.getRealmPoint()
        return realmSentence
    }
}

extension CGPoint {
    func getRealmPoint() -> RealmPoint {
        let point = RealmPoint()
        point.x = x
        point.y = y
        return point
    }
}

extension List {
    func getRealmWords() -> RealmSwift.List<String> {
        let words = RealmSwift.List<String>()
        words.append(objectsIn: self.words)
        return words
    }
}
