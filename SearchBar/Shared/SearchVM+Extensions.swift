//
//  File.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/14/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

// MARK: Update properties after fields change

extension SearchViewModel {
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
