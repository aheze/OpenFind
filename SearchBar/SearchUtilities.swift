//
//  SearchUtilities.swift
//  SearchBar
//
//  Created by Zheng on 10/14/21.
//

import UIKit

extension CGFloat {
    var int: Int {
        return Int(self)
    }
}

extension Int {
    var indexPath: IndexPath {
        return IndexPath(item: self, section: 0)
    }
}
