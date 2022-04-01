//
//  Utilities.swift
//  Find
//
//  Created by Zheng on 11/18/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

/// https://stackoverflow.com/a/29109176/14351818
extension Set {
    func mapSet<U>(transform: (Element) -> U) -> Set<U> {
        return Set<U>(self.lazy.map(transform))
    }
}

/// set a symbol configuration
extension UIImageView {
    func setIconFont(font: UIFont) {
        self.contentMode = .center
        self.preferredSymbolConfiguration = .init(font: font)
    }
}


enum AnimatableUtilities {
    static func mixedValue(from: CGFloat, to: CGFloat, progress: CGFloat) -> CGFloat {
        let value = from + (to - from) * progress
        return value
    }

    static func mixedValue(from: CGPoint, to: CGPoint, progress: CGFloat) -> CGPoint {
        let valueX = from.x + (to.x - from.x) * progress
        let valueY = from.y + (to.y - from.y) * progress
        return CGPoint(x: valueX, y: valueY)
    }
}
