//
//  SearchViewModel.swift
//  SearchBar
//
//  Created by Zheng on 12/2/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

class SearchViewModel: ObservableObject {
    var configuration: SearchConfiguration
    
    /// set from within SearchViewController
    var isLandscape = false
    
    /// set to false if permissions not yet granted
    var enabled = true {
        didSet {
            enabledChanged?()
        }
    }

    var enabledChanged: (() -> Void)?
    
    @Published private(set) var fields = defaultFields {
        didSet {
            updateStringToGradients()
            updateCustomWords()
        }
    }

    var stringToGradients = [String: Gradient]()
    var customWords = [String]()
    
    /// true if changed
    func checkTextChanged(oldFields: [Field], newFields: [Field]) -> Bool {
        let textIsSame = oldFields.elementsEqual(newFields) { oldField, newField in
            oldField.value == newField.value
        }
        
        return !textIsSame
    }
    
    func updateFields(fields: [Field], notify: Bool) {
        let oldValue = self.fields
        self.fields = fields
        
        if notify {
            let textChanged = checkTextChanged(oldFields: oldValue, newFields: fields)
            fieldsChanged?(textChanged)
        }
    }
    
    func updateField(at index: Int, with field: Field, notify: Bool) {
        let oldText = fields[index].value.getText()
        let newText = field.value.getText()
        fields[index] = field
        
        if notify {
            let textChanged = oldText != newText
            fieldsChanged?(textChanged)
        }
    }
    
    func removeField(at index: Int, notify: Bool) {
        let oldValue = fields
        fields.remove(at: index)
        
        if notify {
            let textChanged = checkTextChanged(oldFields: oldValue, newFields: fields)
            fieldsChanged?(textChanged)
        }
    }
    
    func appendField(field: Field, notify: Bool) {
        let oldValue = fields
        fields.append(field)
        
        if notify {
            let textChanged = checkTextChanged(oldFields: oldValue, newFields: fields)
            fieldsChanged?(textChanged)
        }
    }
    
    /// set all the properties without creating a new instance
    func replaceInPlace(with model: SearchViewModel, notify: Bool) {
        let oldValue = fields
        isLandscape = model.isLandscape
        fields = model.fields
        stringToGradients = model.stringToGradients
        customWords = model.customWords
        
        if notify {
            let textChanged = checkTextChanged(oldFields: oldValue, newFields: fields)
            fieldsChanged?(textChanged)
        }
    }
    
    /// must be implemented later on
    /// `Bool` - true when **text** has changed, false when text stayed the same
    var fieldsChanged: ((Bool) -> Void)?
    
    var dismissKeyboard: (() -> Void)?

    init(configuration: SearchConfiguration) {
        self.configuration = configuration
    }
}
