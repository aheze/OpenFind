//
//  Model.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/1/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import Photos
import UIKit

struct Photo: Hashable {
    
    var asset: PHAsset
    var metadata: PhotoMetadata?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(asset)
    }
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        lhs.asset == rhs.asset
    }
}

struct PhotoMetadata {
    var id = UUID()
    var assetIdentifier = ""
    var sentences = [Sentence]()
    var isStarred = false
    var dateCreated = Date()
}

struct Sentence {
    var rect: CGRect?
    var string = ""
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
    
    var displayedName: String {
        return name.isEmpty ? "Untitled" : name
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
