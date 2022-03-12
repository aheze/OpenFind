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
    /// average angle of the sentence. Positive = up, negative = down from the right of the x axis
    var angle: CGFloat {
        guard
            let firstRangeToFrame = rangesToFrames.min(by: { $0.key.lowerBound < $1.key.lowerBound }),
            let lastRangeToFrame = rangesToFrames.min(by: { $0.key.upperBound > $1.key.upperBound })
        else { return 0 }

        /// differences are the distance from the unit circle origin (`firstRangeToFrame`) to the outside point (`lastRangeToFrame`)
        let yDifference = firstRangeToFrame.value.midY - lastRangeToFrame.value.midY
        let xDifference = lastRangeToFrame.value.midX - firstRangeToFrame.value.midX
        let angle = atan2(yDifference, xDifference)
        return angle
    }

    var sentenceFrame: CGRect {
        let boundingFrame = boundingFrame()
        let yInset = boundingFrame.height * abs(sin(angle))
        let frame = boundingFrame.insetBy(dx: 0, dy: yInset)
        return frame
    }

    /// get the word range that contains a character index
    func rangeToFrame(containing index: Int) -> (range: Range<Int>, frame: CGRect)? {
        guard let rangeToFrame = rangesToFrames.first(
            where: { range, _ in range.contains(index) || range.upperBound == index }
        ) else {
            return nil
        }
        return (rangeToFrame.key, rangeToFrame.value)
    }

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

    func boundingFrame() -> CGRect {
        guard
            let firstRangeToFrame = rangesToFrames.min(by: { $0.key.lowerBound < $1.key.lowerBound }),
            let lastRangeToFrame = rangesToFrames.min(by: { $0.key.upperBound > $1.key.upperBound })
        else { return .zero }

        let frame = firstRangeToFrame.value.union(lastRangeToFrame.value)
        return frame
    }

    func position(for targetRange: Range<Int>) -> Highlight.Position {
        let position = Highlight.Position(
            sentenceFrame: sentenceFrame,
            globalCenter: globalCenter(for: targetRange),
            horizontalOffset: horizontalOffset(for: targetRange.lowerBound),
            length: length(for: targetRange),
            angle: angle
        )
        return position
    }

    func globalCenter(for targetRange: Range<Int>) -> CGPoint {
        let frame = frame(for: targetRange)
        return CGPoint(x: frame.midX, y: frame.midY)
    }

//    func horizontalOffset(for index: Int, containingRangeToFrame: (range: Range<Int>, frame: CGRect)? = nil) -> CGFloat {
//        guard let rangeToFrame = containingRangeToFrame ?? rangeToFrame(containing: index) else { return .zero }
    func horizontalOffset(for index: Int) -> CGFloat {
        guard let rangeToFrame = rangeToFrame(containing: index) else { return .zero }

        let gridWidth = rangeToFrame.frame.width / CGFloat(rangeToFrame.range.count)
        let offsetFromWord = gridWidth * CGFloat(index - rangeToFrame.range.lowerBound)

        /// distance from the beginning of the sentence
        let wordOffset = CGPointDistance(from: rangeToFrame.frame.origin, to: boundingFrame().origin)
        let horizontalOffset = wordOffset + offsetFromWord
        return horizontalOffset
    }

    func length(for targetRange: Range<Int>) -> CGFloat {
        /// get the ranges that contains the target range.
        let startFrame = characterFrame(for: targetRange.lowerBound)
        let endFrame = characterFrame(for: targetRange.upperBound - 1)
        let distance = CGPointDistance(
            from: CGPoint(x: startFrame.minX, y: startFrame.midY),
            to: CGPoint(x: endFrame.maxX, y: startFrame.midY)
        )
        return distance
    }

    /// get the frame for a range. This range doesn't need to be limited to individual words.
    /// Usually no need to use this, use `position` instead.
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
        guard let rangeToFrame = rangeToFrame(containing: index) else { return .zero }

        let gridWidth = rangeToFrame.frame.width / CGFloat(rangeToFrame.range.count)

        let frame: CGRect
        switch angle.radiansToDegrees {
        /// horizontal
        case -30 ..< 30:
            let characterLength = gridWidth
            let characterXOffset = gridWidth * CGFloat(index - rangeToFrame.range.lowerBound)

            let yInset = rangeToFrame.frame.height * abs(sin(angle)) / 2
            frame = CGRect(
                x: rangeToFrame.frame.origin.x + characterXOffset,
                y: rangeToFrame.frame.origin.y,
                width: characterLength,
                height: rangeToFrame.frame.height
            )
            .insetBy(dx: 0, dy: yInset)
        default:
            frame = rangeToFrame.frame
        }

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
