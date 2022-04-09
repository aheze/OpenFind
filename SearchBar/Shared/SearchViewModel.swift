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
    
    func updateFields(fields: [Field], notify: Bool) {
        let oldValue = self.fields
        self.fields = fields
        
        if notify {
            let textChanged = checkTextChanged(oldValue: oldValue, newValue: fields)
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
            let textChanged = checkTextChanged(oldValue: oldValue, newValue: fields)
            fieldsChanged?(textChanged)
        }
    }
    
    func appendField(field: Field, notify: Bool) {
        let oldValue = fields
        fields.append(field)
        
        if notify {
            let textChanged = checkTextChanged(oldValue: oldValue, newValue: fields)
            fieldsChanged?(textChanged)
        }
    }
    
    /// true if changed
    func checkTextChanged(oldValue: [Field], newValue: [Field]) -> Bool {
        let oldText = oldValue.map { $0.value.getText() }
        let newText = fields.map { $0.value.getText() }
        let textChanged = oldText != newText
        return textChanged
    }
    
    /// set all the properties without creating a new instance
    func replaceInPlace(with model: SearchViewModel, notify: Bool) {
        let oldValue = fields
        isLandscape = model.isLandscape
        fields = model.fields
        stringToGradients = model.stringToGradients
        customWords = model.customWords
        
        if notify {
            let textChanged = checkTextChanged(oldValue: oldValue, newValue: fields)
            fieldsChanged?(textChanged)
        }
    }
    
    /// must be implemented later on
    /// `Bool` - true when **text** has changed, false when text stayed the same
    var fieldsChanged: ((Bool) -> Void)?
    
    var dismissKeyboard: (() -> Void)?
    
    /// array of values
    var values: [Field.FieldValue] {
        return fields.dropLast().map { $0.value }
    }
    
    /// array of text
    var text: [String] {
        return values.map { $0.getText().trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
    }
    
    /// if the search text is empty or not
    var isEmpty: Bool {
        let isEmpty = text.joined().trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return isEmpty
    }
    
    init(configuration: SearchConfiguration) {
        self.configuration = configuration
    }
}
