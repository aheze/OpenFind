//
//  SpecifiedExtensions.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import RealmSwift
import UIKit

/**
 Might contain some dependencies, like `RealmSwift`
 */

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
