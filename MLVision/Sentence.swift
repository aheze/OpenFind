//
//  Sentence.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/11/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

struct Sentence {
    var string: String

    /// contains ranges of each word in the string
    var rangesToFrames: [Range<Int>: CGRect]

    /// average angle of the sentence. Positive = up, negative = down from the right of the x axis
    var angle: CGFloat

    /// a frame that surrounds all the letters
    var boundingFrame: CGRect

    /// once rotated to the `angle`, this should closely hug the letters.
    var sentenceFrame: CGRect

    init(string: String, rangesToFrames: [Range<Int>: CGRect]) {
        self.string = string
        self.rangesToFrames = rangesToFrames

        self.angle = Sentence.getAngle(rangesToFrames: rangesToFrames)
        self.boundingFrame = Sentence.getBoundingFrame(rangesToFrames: rangesToFrames)
        self.sentenceFrame = Sentence.getSentenceFrame(angle: angle, boundingFrame: boundingFrame)
    }
}

extension Sentence {
    static func getAngle(rangesToFrames: [Range<Int>: CGRect]) -> CGFloat {
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

    static func getBoundingFrame(rangesToFrames: [Range<Int>: CGRect]) -> CGRect {
        guard
            let firstRangeToFrame = rangesToFrames.min(by: { $0.key.lowerBound < $1.key.lowerBound }),
            let lastRangeToFrame = rangesToFrames.min(by: { $0.key.upperBound > $1.key.upperBound })
        else { return .zero }

        let frame = firstRangeToFrame.value.union(lastRangeToFrame.value)
        return frame
    }

    static func getSentenceFrame(angle: CGFloat, boundingFrame: CGRect) -> CGRect {
        /// should be bigger
        return insetFrameFromRotation(angle: angle, frame: boundingFrame)
    }

    /// adjust the frame after an angle rotation
    static func insetFrameFromRotation(angle: CGFloat, frame: CGRect) -> CGRect {
        let width = frame.width / cos(angle)
        let height = frame.height * cos(angle)

        let newFrame = frame.insetBy(
            dx: (width - frame.width) / 2,
            dy: (frame.height - height) / 2
        )
        return newFrame
    }
}

extension Sentence {
    /// get the word range that contains a character index
    func rangeToFrame(containing index: Int) -> (range: Range<Int>, frame: CGRect)? {
        guard let rangeToFrame = rangesToFrames.first(
            where: { range, _ in range.contains(index) || range.upperBound == index }
        ) else {
            return nil
        }
        let frame = Sentence.insetFrameFromRotation(angle: angle, frame: rangeToFrame.value)
        return (rangeToFrame.key, frame)
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

    /// get the position of a highlight
    func position(for targetRange: Range<Int>) -> Highlight.Position {
        let highlightFrame = frame(for: targetRange)

        let distanceFromCenter = CGPointDistance(from: highlightFrame.center, to: sentenceFrame.center)

        /// where the highlight will be located and the angle rotation applied
        let highlightCenter: CGPoint

        /// if highlight is to the right of the sentence
        if highlightFrame.center.x > sentenceFrame.center.x {
            let offsetXFromCenter = cos(angle) * distanceFromCenter
            let offsetYFromCenter = -sin(angle) * distanceFromCenter

            highlightCenter = CGPoint(
                x: sentenceFrame.midX + offsetXFromCenter,
                y: sentenceFrame.midY + offsetYFromCenter
            )
        } else {
            let offsetXFromCenter = -cos(angle) * distanceFromCenter
            let offsetYFromCenter = sin(angle) * distanceFromCenter

            highlightCenter = CGPoint(
                x: sentenceFrame.midX + offsetXFromCenter,
                y: sentenceFrame.midY + offsetYFromCenter
            )
        }

        let position = Highlight.Position(
            originalPoint: highlightFrame.center,
            pivotPoint: sentenceFrame.center,
            center: highlightCenter,
            size: highlightFrame.size,
            angle: angle
        )

        return position
    }

    /// get the frame for a range. This range doesn't need to be limited to individual words.
    /// Usually no need to use this, use `position` instead.
    func frame(for targetRange: Range<Int>) -> CGRect {
        /// get the ranges that contains the target range.
        let startFrame = characterFrame(for: targetRange.lowerBound)
        let endFrame = characterFrame(for: targetRange.upperBound)

        let frame = startFrame.union(endFrame)
        return frame
    }

    /// index: The index of the character, inside the parent string from the `sentence`
    func characterFrame(for index: Int) -> CGRect {
        /// get the ranges that contains the target index
        guard let rangeToFrame = rangeToFrame(containing: index) else { return .zero }
        let gridWidth = rangeToFrame.frame.width / CGFloat(rangeToFrame.range.count)
        let characterLength = gridWidth
        let characterXOffset = gridWidth * CGFloat(index - rangeToFrame.range.lowerBound)

        let frame = CGRect(
            x: rangeToFrame.frame.origin.x + characterXOffset,
            y: rangeToFrame.frame.origin.y,
            width: characterLength,
            height: rangeToFrame.frame.height
        )
        return frame
    }
}
