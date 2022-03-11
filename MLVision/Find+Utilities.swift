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
            let indices = string.indicesOf(string: searchString)
            let ranges = indices.map { $0 ..< $0 + searchString.count }
            let result = RangeResult(string: searchString, ranges: ranges)
            results.append(result)
        }
        return results
    }

    /// get the frame for a range. This range doesn't need to be limited to individual words.
    func frame(for targetRange: Range<Int>) -> CGRect {
        /// get the ranges that contains the target range.
        guard
            let startRangeToFrame = rangesToFrames.first(where: { range, _ in range.contains(targetRange.lowerBound) }),
            let endRangeToFrame = rangesToFrames.first(where: { range, _ in range.contains(targetRange.upperBound) })
        else { return .zero }

        let startFrame = characterFrame(for: targetRange.lowerBound, in: (range: startRangeToFrame.key, frame: startRangeToFrame.value))
        let endFrame = characterFrame(for: targetRange.lowerBound, in: (range: endRangeToFrame.key, frame: endRangeToFrame.value))

        let frame = startFrame.union(endFrame)
        return frame
    }

    /// index: The index of the character, inside the parent string from the `sentence`
    /// rangeToFrame: The `rangeToFrame` that contains this index.
    func characterFrame(for index: Int, in rangeToFrame: (range: Range<Int>, frame: CGRect)) -> CGRect {
        let gridWidth = rangeToFrame.frame.width / CGFloat(rangeToFrame.range.count)
        let gridHeight = rangeToFrame.frame.height / CGFloat(rangeToFrame.range.count)

        /// length of a character (a square)
        let characterLength = max(gridWidth, gridHeight)
        let characterX = gridWidth * CGFloat(rangeToFrame.range.count)
        let characterY = gridHeight * CGFloat(rangeToFrame.range.count)

        let frame = CGRect(x: characterX, y: characterY, width: characterLength, height: characterLength)
        return frame
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
