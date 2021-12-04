//
//  Utilities.swift
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

extension BinaryInteger {
    var degreesToRadians: CGFloat { CGFloat(self) * .pi / 180 }
}

extension FloatingPoint {
    var degreesToRadians: Self { self * .pi / 180 }
    var radiansToDegrees: Self { self * 180 / .pi }
}

extension Int {
    var indexPath: IndexPath {
        return IndexPath(item: self, section: 0)
    }
}
