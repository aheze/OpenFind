//
//  IndexMatcher.swift
//  Find
//
//  Created by Andrew on 1/5/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import Foundation

class IndexMatcher: Hashable {
    var section = 0
    var row = 0
    static func == (lhs: IndexMatcher, rhs: IndexMatcher) -> Bool {
        return lhs.section == rhs.section && lhs.row == rhs.row
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(section)
        hasher.combine(row)
    }
    
}
