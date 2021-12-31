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
            value: .string(""),
            attributes: .init(
                defaultColor: Constants.defaultHighlightColor.getFieldColor(for: 0)
            )
        ),
        Field(
            value: .addNew(""),
            attributes: .init(
                defaultColor: Constants.defaultHighlightColor.getFieldColor(for: 1)
            )
        )
    ]
    
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
            case .string(let string):
                var existingGradient = stringToGradients[string] ?? Gradient()
                existingGradient.colors.append(field.attributes.selectedColor ?? field.attributes.defaultColor)
                existingGradient.alpha = field.attributes.alpha
                stringToGradients[string] = existingGradient
            case .list(let list):
                let strings = list.contents
                for string in strings {
                    var existingGradient = stringToGradients[string] ?? Gradient()
                    existingGradient.colors.append(field.attributes.selectedColor ?? field.attributes.defaultColor)
                    existingGradient.alpha = field.attributes.alpha
                    stringToGradients[string] = existingGradient
                }
            case .addNew(_):
                continue
            }
        }
        return stringToGradients
    }
}
