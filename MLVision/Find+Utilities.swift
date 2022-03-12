//
//  Find+Utilities.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/30/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//

import UIKit
import Vision

struct RangeResult: Hashable {
    var string: String
    var ranges: [Range<Int>]
}

extension StringProtocol {
    /// a range of Ints that represent each word in the string
    func ranges() -> [Range<Int>] {
        var ranges = [Range<Int>]()
        enumerateSubstrings(in: startIndex..., options: .byWords) { component, _, range, _ in
            let start = distance(to: range.lowerBound)
            let end = distance(to: range.upperBound)
            ranges.append(start ..< end)
        }
        return ranges
    }
}

extension String {
    func indicesOf(string: String) -> [Int] {
        var indices = [Int]()
        var searchStartIndex = startIndex

        while
            searchStartIndex < endIndex,
            let range = range(of: string, range: searchStartIndex ..< endIndex),
            !range.isEmpty
        {
            let index = distance(from: startIndex, to: range.lowerBound)
            indices.append(index)
            searchStartIndex = range.upperBound
        }

        return indices
    }
}

extension Collection {
    func distance(to index: Index) -> Int { distance(from: startIndex, to: index) }
}

extension VNRectangleObservation {
    func getFrame() -> CGRect {
        var frame = boundingBox
        frame.origin.y = 1 - frame.origin.y - frame.height /// get top-left
        return frame
    }
}
