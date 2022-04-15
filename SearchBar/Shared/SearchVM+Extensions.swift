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
    func trimWhitespaceIfNeeded(from string: String) -> String {
        let shouldKeepWhitespace = getShouldKeepWhitespace?() ?? false

        if shouldKeepWhitespace {
            return string
        } else {
            return string.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    func updateStringToGradients() {
        var stringToGradients = [String: Gradient]()
        for field in fields {
            switch field.value {
            case .word(let word):
                let string = trimWhitespaceIfNeeded(from: word.string)
                guard !string.isEmpty else { continue }

                var existingGradient = stringToGradients[string] ?? Gradient()
                existingGradient.colors.append(field.overrides.selectedColor ?? UIColor(hex: word.color))
                existingGradient.alpha = field.overrides.alpha
                stringToGradients[string] = existingGradient
            case .list(let list, _):

                let strings = list.words
                guard list.containsWords else { continue }
                for string in strings {
                    let string = trimWhitespaceIfNeeded(from: string)

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
            case .list(let list, _):
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
