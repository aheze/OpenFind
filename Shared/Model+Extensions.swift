//
//  Model+Extensions.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import RealmSwift
import UIKit

extension PhotoMetadata {
    func getRealmSentences() -> RealmSwift.List<RealmPhotoMetadataSentence> {
        let realmSentences = RealmSwift.List<RealmPhotoMetadataSentence>()
        for sentence in self.sentences {
            let realmSentence = sentence.getRealmSentence()
            realmSentences.append(realmSentence)
        }
        return realmSentences
    }
}

extension Sentence {
    func getRealmSentence() -> RealmPhotoMetadataSentence {
        let realmSentence = RealmPhotoMetadataSentence()

        let realmRect = RealmRect(
            x: frame.origin.x,
            y: frame.origin.y,
            width: frame.width,
            height: frame.height
        )
        realmSentence.string = string
        realmSentence.frame = realmRect
        realmSentence.confidence = confidence
        return realmSentence
    }
}

extension List {
    func getRealmWords() -> RealmSwift.List<String> {
        let words = RealmSwift.List<String>()
        words.append(objectsIn: self.words)
        return words
    }
}
