//
//  Utilities.swift
//  SearchBar
//
//  Created by Zheng on 10/14/21.
//

import UIKit

extension Collection {

    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
