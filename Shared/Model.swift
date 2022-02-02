//
//  Model.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/1/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

/**
 Models for the search bar. Includes color.
 */

enum Value {
    case word(Word)
    case list(List)
}

struct Word {
    var id = UUID()
    var string = ""
    var color: UInt = 0x00AEEF
}

struct List: Identifiable {
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
