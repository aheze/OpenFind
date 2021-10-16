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
    
    
    /// width of text label
    var valueFrameWidth = CGFloat(200)
    
    
    enum Value {
        case string(String)
        case list(List)
    }
    
    func getText() -> String {
        switch self.value {
        case .string(let string):
            return string
        case .list(let list):
            return list.name
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
