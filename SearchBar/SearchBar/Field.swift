//
//  Field.swift
//  SearchBar
//
//  Created by Zheng on 10/14/21.
//

import Foundation

struct Field {
    var value = Value.string("")
    
    /// delete button deletes the entire field
    /// clear button is normal, shown when is editing no matter what
    var showingDeleteButton = false
    
    
    
    enum Value {
        case string(String)
        case list(List)
    }
}

struct List {
    var name = ""
    var desc = ""
    var contents = [String]()
    var iconImageName = ""
    var iconColorName = ""
    var dateCreated = Date()
}
