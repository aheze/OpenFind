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
            fieldsChanged?()
        }
    }
    
    var fieldsChanged: (() -> Void)?
    
    var values: [Field.Value] {
        return fields.dropLast().map { $0.value }
    }
    
    struct Gradient {
        var colors = [UIColor]()
        var alpha = CGFloat(1)
    }
    
    var stringToGradients: [String: Gradient] {
        
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
        return stringToGradients
    }
}
