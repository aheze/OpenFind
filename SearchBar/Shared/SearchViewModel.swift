//
//  SearchViewModel.swift
//  SearchBar
//
//  Created by Zheng on 12/2/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

class SearchViewModel: ObservableObject {
    struct Gradient {
        var colors = [UIColor]()
        var alpha = CGFloat(1)
    }

    var configuration: SearchConfiguration
    
    /// set from within SearchViewController
    var isLandscape = false
    
    @Published var fields = defaultFields {
        didSet {
            updateStringToGradients()
            updateCustomWords()
            fieldsChanged?(oldValue, fields)
        }
    }
    
    var stringToGradients = [String: Gradient]()
    var customWords = [String]()
    
    /// must be implemented later on
    var fieldsChanged: (([Field], [Field]) -> Void)?
    
    var dismissKeyboard: (() -> Void)?
    
    var values: [Field.FieldValue] {
        return fields.dropLast().map { $0.value }
    }
    
    init(configuration: SearchConfiguration) {
        self.configuration = configuration
    }

    func setFieldValue(at index: Int, value: () -> Field.FieldValue) {
        fields[index].value = value()
    }
    
    func updateStringToGradients() {
        var stringToGradients = [String: Gradient]()
        for field in fields {
            switch field.value {
            case .word(let word):
                guard !word.string.isEmpty else { continue }
                var existingGradient = stringToGradients[word.string] ?? Gradient()
                existingGradient.colors.append(field.overrides.selectedColor ?? UIColor(hex: word.color))
                existingGradient.alpha = field.overrides.alpha
                stringToGradients[word.string] = existingGradient
            case .list(let list):
                let strings = list.words
                guard list.containsWords else { continue }
                for string in strings {
                    var existingGradient = stringToGradients[string] ?? Gradient()
                    existingGradient.colors.append(field.overrides.selectedColor ?? UIColor(hex: list.color))
                    existingGradient.alpha = field.overrides.alpha
                    stringToGradients[string] = existingGradient
                }
            case .addNew:
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
                let contents = Set(list.words)
                words.formUnion(contents)
            case .addNew:
                continue
            }
        }
        customWords = Array(words)
    }
}

extension SearchViewModel {
    func getBackgroundColor() -> UIColor {
        if !stringToGradients.isEmpty {
            
            //// active
            return configuration.fieldActiveBackgroundColor
        } else {
            return configuration.fieldBackgroundColor
        }
    }
    
    func getTotalHeight() -> CGFloat {
        if isLandscape {
            return configuration.cellHeight + configuration.barTopPaddingLandscape + configuration.barBottomPaddingLandscape
        } else {
            return configuration.cellHeight + configuration.barTopPadding + configuration.barBottomPadding
        }
    }
}

extension SearchViewModel {
    /// set all the properties without creating a new instance
    func replaceInPlace(with model: SearchViewModel) {
        isLandscape = model.isLandscape
        fields = model.fields
        stringToGradients = model.stringToGradients
        customWords = model.customWords
    }
}

extension SearchViewModel {
    static let defaultFields = [
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
    ]
}
