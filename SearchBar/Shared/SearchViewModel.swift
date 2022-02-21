//
//  SearchViewModel.swift
//  SearchBar
//
//  Created by Zheng on 12/2/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

/// Model for the collection view
class SearchCollectionViewModel: ObservableObject {
    /// index of focused/expanded cell
    @Published var focusedCellIndex: Int? {
        didSet {
            focusedCellIndexChanged?(oldValue, focusedCellIndex)
        }
    }

    /// old / new
    var focusedCellIndexChanged: ((Int?, Int?) -> Void)?
    
    var keyboardShown = false
    
    /// prepared before?
    var preparedOnce = false
    
    /// pass back data
    var highlightAddNewField: ((Bool) -> Void)?
    
    /// fast swipe, instantly convert
    var convertAddNewCellToRegularCell: ((@escaping () -> Void) -> Void)?
    var currentConvertingAddNewCellToRegularCell = false /// if in progress of converting
    
    /// collection view is about to reach the end (auto-scrolling) or has reached the end
    var reachedEndBeforeAddWordField = false
    
    /// call this from the scroll view delegate when
    /// 1. finger is down
    /// 2. `reachedEnd` is true
    var shouldUseOffsetWithAddNew = false
    
    /// when deleting cells
    var deletedIndex: Int?
    var fallbackIndex: Int?
    
    /// showing (past the point where it will auto-scroll) the last field or not
    var highlightingAddWordField = false
    
    /// get the widths of cells
    var getFullCellWidth: ((Int) -> CGFloat)?
}

class SearchViewModel: ObservableObject {
    var configuration: SearchConfiguration
    var isLandscape = false
    
    init(configuration: SearchConfiguration) {
        self.configuration = configuration
    }
    
    @Published var fields = defaultFields {
        didSet {
            updateStringToGradients()
            fieldsChanged?(oldValue, fields)
        }
    }

    var fieldsChanged: (([Field], [Field]) -> Void)?
    func setFieldValue(at index: Int, value: () -> Field.FieldValue) {
        fields[index].value = value()
    }

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
    
    func getTotalHeight() -> CGFloat {
        if isLandscape {
            return configuration.cellHeight + configuration.barTopPaddingLandscape + configuration.barBottomPaddingLandscape
        } else {
            return configuration.cellHeight + configuration.barTopPadding + configuration.barBottomPadding
        }
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
