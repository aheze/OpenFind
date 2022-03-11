//
//  Find+Utilities.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/30/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//

import UIKit
import Vision

struct Sentence {
    var string: String

    /// contains ranges of each word in the string
    var rangesToFrames: [Range<Int>: CGRect]
}

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

extension Sentence {
    /// get the ranges of search strings in the `string`
    func ranges(of searchStrings: [String]) -> [RangeResult] {
        var results = [RangeResult]()

        for searchString in searchStrings {
            let indices = string.lowercased().indicesOf(string: searchString.lowercased())
            if indices.isEmpty { continue }
            let ranges = indices.map { $0 ..< $0 + searchString.count }
            let result = RangeResult(string: searchString, ranges: ranges)
            results.append(result)
        }
        return results
    }

    func string(for targetRange: Range<Int>) -> String {
        let start = string.index(string.startIndex, offsetBy: targetRange.lowerBound)
        let end = string.index(string.startIndex, offsetBy: targetRange.upperBound)
        return String(string[start ..< end])
    }

    /// get the frame for a range. This range doesn't need to be limited to individual words.
    func frame(for targetRange: Range<Int>) -> CGRect {
        /// get the ranges that contains the target range.
        let startFrame = characterFrame(for: targetRange.lowerBound)
        let endFrame = characterFrame(for: targetRange.upperBound - 1)

        let frame = startFrame.union(endFrame)
        return frame
    }

    /// index: The index of the character, inside the parent string from the `sentence`
    /// rangeToFrame: The `rangeToFrame` that contains this index.
    func characterFrame(for index: Int) -> CGRect {
        /// get the ranges that contains the target range.
        guard let rangeToFrame = rangesToFrames.first(
            where: { range, _ in range.contains(index) || range.upperBound == index }
        ) else {
            return .zero
        }

        let gridWidth = rangeToFrame.value.width / CGFloat(rangeToFrame.key.count)
        let gridHeight = rangeToFrame.value.height / CGFloat(rangeToFrame.key.count)

        /// length of a character (a square)
        let characterLength = max(gridWidth, gridHeight)

        /// get offset within the word's frame. `index - rangeToFrame.range.lowerBound` is the index relative to the word.
        let characterXOffset = gridWidth * CGFloat(index - rangeToFrame.key.lowerBound)
        let characterYOffset = gridHeight * CGFloat(index - rangeToFrame.key.lowerBound)

        let frame = CGRect(
            x: rangeToFrame.value.origin.x + characterXOffset,
            y: rangeToFrame.value.origin.y + characterYOffset,
            width: characterLength,
            height: characterLength
        )

        return frame
    }

    func averageAngle() {}
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
