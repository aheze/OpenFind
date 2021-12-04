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
        Field(text: .init(value: .string(""), colorIndex: 0)),
        Field(text: .init(value: .addNew(""), colorIndex: 1))
    ]
}
