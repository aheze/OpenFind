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

struct List {
    var id = UUID()
    var name = ""
    var desc = ""
    var icon = ""
    var color: UInt = 0x00AEEF
    var words = [String]()
    var dateCreated = Date()
}

struct EditableList {
    var id: UUID
    var name: String
    var desc: String
    var icon: String
    var color: UInt
    var words: [EditableWord]
    var dateCreated: Date
}

struct EditableWord {
    let id = UUID()
    var string: String
}
