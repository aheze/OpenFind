//
//  Model.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/1/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

/**
 Models for the search bar. Includes color.
 */

enum Value {
    case word(Word)
    case list(List)
}

struct Gradient: Hashable {
    var colors = [UIColor]()
    var alpha = CGFloat(1)
}

// MARK: Finding

struct RangeResult: Hashable {
    var string: String
    var ranges: [Range<Int>]
}

struct DataSourceSectionTemplate: Hashable {
    var id = 0

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: DataSourceSectionTemplate, rhs: DataSourceSectionTemplate) -> Bool {
        lhs.id == rhs.id
    }
}

//class RealmArray<Element> {
//    
//}
