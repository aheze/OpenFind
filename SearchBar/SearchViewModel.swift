//
//  SearchViewModel.swift
//  SearchBar
//
//  Created by Zheng on 12/2/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

class SearchViewModel: ObservableObject {
    var availableLists = [List]()
    var fields = [
        Field(
            value: .string(""),
            attributes: .init(
                defaultColor: Constants.defaultHighlightColor.getFieldColor(for: 0)
            )
        ),
        Field(
            value: .string(""),
            attributes: .init(
                defaultColor: Constants.defaultHighlightColor.getFieldColor(for: 0)
            )
        ),
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
}
