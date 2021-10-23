//
//  Field.swift
//  SearchBar
//
//  Created by Zheng on 10/14/21.
//

import UIKit

struct Field {
    var value = Value.string("")
    
    /// delete button deletes the entire field
    /// clear button is normal, shown when is editing no matter what
    var showingDeleteButton = false
    
    
    /// width of text label + side views, nothing more
    var fieldHuggingWidth = CGFloat(200)
    
    
    enum Value {
        case string(String)
        case list(List)
        case addNew
    }
    
    
    func getText() -> String {
        switch self.value {
        case .string(let string):
            return string
        case .list(let list):
            return list.name
        case .addNew:
            return "Add Word"
        }
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
