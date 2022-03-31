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

extension PhotoMetadata {
    func getRealmSentences() -> RealmSwift.List<RealmSentence> {
        let realmSentences = RealmSwift.List<RealmSentence>()
        for sentence in self.sentences {
            let realmSentence = sentence.getRealmSentence()
            realmSentences.append(realmSentence)
        }
        return realmSentences
    }
}

extension Sentence {
    func getRealmSentence() -> RealmSentence {
        let realmComponents = RealmSwift.List<RealmSentenceComponent>()
        for component in components {
            let realmRange = RealmIntRange(lowerBound: component.range.lowerBound, upperBound: component.range.upperBound)
            let realmRect = RealmRect(
                x: component.frame.origin.x,
                y: component.frame.origin.y,
                width: component.frame.width,
                height: component.frame.height
            )

            let realmComponent = RealmSentenceComponent()
            realmComponent.range = realmRange
            realmComponent.frame = realmRect
            realmComponents.append(realmComponent)
        }

        let realmSentence = RealmSentence()
        realmSentence.string = string
        realmSentence.components = realmComponents
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

