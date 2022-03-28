//
//  List.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

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

    /// false if words is empty
    var containsWords: Bool {
        let joined = self.words.joined()
        return !joined.isEmpty
    }

    var displayedName: String {
        return self.name.isEmpty ? "Untitled" : self.name
    }
    
    static func == (lhs: List, rhs: List) -> Bool {
        lhs.id == rhs.id
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
