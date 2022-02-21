//
//  Model.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/1/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Photos
import RealmSwift
import UIKit

struct Photo: Hashable {
    var asset: PHAsset
    var metadata: PhotoMetadata?

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.asset)
    }

    static func == (lhs: Photo, rhs: Photo) -> Bool {
        lhs.asset == rhs.asset
    }
}

struct PhotoMetadata {
    var assetIdentifier = ""
    var sentences = [Sentence]()
    var isScanned = false
    var isStarred = false

    func getRealmSentences() -> RealmSwift.List<RealmPhotoMetadataSentence> {
        let realmSentences = RealmSwift.List<RealmPhotoMetadataSentence>()
        for sentence in self.sentences {
            let realmSentence = sentence.getRealmSentence()
            realmSentences.append(realmSentence)
        }
        return realmSentences
    }
}

struct Sentence {
    var rect: CGRect?
    var string = ""

    func getRealmSentence() -> RealmPhotoMetadataSentence {
        let realmSentence = RealmPhotoMetadataSentence()
        if let rect = self.rect {
            let realmRect = RealmRect(
                x: rect.origin.x,
                y: rect.origin.y,
                width: rect.width,
                height: rect.height
            )
            realmSentence.rect = realmRect
        }
        realmSentence.string = self.string
        return realmSentence
    }
}

/**
 Models for the search bar. Includes color.
 */

enum Value {
    case word(Word)
    case list(List)
}

struct Word: Equatable {
    var id = UUID()
    var string = ""
    var color: UInt = 0x00AEEF
}

struct List: Identifiable, Equatable {
    var id = UUID()
    var name = ""
    var desc = ""
    var icon = "bubble.left"
    var color: UInt = 0x007EEF
    var words: [String] = [""]
    var dateCreated = Date()

    func getEditableList() -> EditableList {
        let editableList = EditableList(
            id: self.id,
            name: self.name,
            desc: self.desc,
            icon: self.icon,
            color: self.color,
            words: self.words.map { EditableWord(string: $0) },
            dateCreated: self.dateCreated
        )
        return editableList
    }
    
    func getRealmWords() -> RealmSwift.List<String> {
        let words = RealmSwift.List<String>()
        words.append(objectsIn: self.words)
        return words
    }

    var displayedName: String {
        return self.name.isEmpty ? "Untitled" : self.name
    }
}

struct EditableList {
    var id: UUID
    var name: String
    var desc: String
    var icon: String
    var color: UInt
    var words: [EditableWord]
    var dateCreated: Date

    func getList() -> List {
        let list = List(
            id: self.id,
            name: self.name,
            desc: self.desc,
            icon: self.icon,
            color: self.color,
            words: self.words.map { $0.string },
            dateCreated: self.dateCreated
        )
        return list
    }
}

struct EditableWord {
    let id = UUID()
    var string: String
}
