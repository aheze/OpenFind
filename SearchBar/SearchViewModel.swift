//
//  SearchViewModel.swift
//  SearchBar
//
//  Created by Zheng on 12/2/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

class SearchViewModel: ObservableObject {
    
    var fields = [
        Field(
            value: .word(
                .init(
                    string: "",
                    color: Constants.defaultHighlightColor.getFieldColor(for: 0).hex
                )
            )
        ),
        Field(
            value: .addNew(
                .init(
                    string: "",
                    color: Constants.defaultHighlightColor.getFieldColor(for: 1).hex
                )
            )
        )
    ] {
        didSet {
            fieldsChanged?(oldValue, fields)
            updateStringToGradients()
        }
    }
    
    var fieldsChanged: (([Field], [Field]) -> Void)?
    
    var values: [Field.FieldValue] {
        return fields.dropLast().map { $0.value }
    }
    
    struct Gradient {
        var colors = [UIColor]()
        var alpha = CGFloat(1)
    }
    
    var stringToGradients = [String: Gradient]()
    var customWords = [String]()
    
    func updateStringToGradients() {
        
        var stringToGradients = [String: Gradient]()
        for field in fields {
            switch field.value {
            case .word(let word):
                var existingGradient = stringToGradients[word.string] ?? Gradient()
                existingGradient.colors.append(field.overrides.selectedColor ?? UIColor(hex: word.color))
                existingGradient.alpha = field.overrides.alpha
                stringToGradients[word.string] = existingGradient
            case .list(let list):
                let strings = list.contents
                for string in strings {
                    var existingGradient = stringToGradients[string] ?? Gradient()
                    existingGradient.colors.append(field.overrides.selectedColor ?? UIColor(hex: list.color))
                    existingGradient.alpha = field.overrides.alpha
                    stringToGradients[string] = existingGradient
                }
            case .addNew(_):
                continue
            }
        }
        self.stringToGradients = stringToGradients
    }
    
    func updateCustomWords() {
        var words = Set<String>()
        for value in values {
            switch value {
            case .word(let word):
                words.insert(word.string)
            case .list(let list):
                let contents = Set(list.contents)
                words.formUnion(contents)
            case .addNew(_):
                continue
            }
        }
        self.customWords = Array(words)
    }

}
