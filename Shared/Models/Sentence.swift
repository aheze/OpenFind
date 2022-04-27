//
//  Sentence.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/11/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

struct FastSentence {
    var string: String
    var frame: CGRect

    /// If self is a sentence
    func getWord(word: String, at index: Int) -> FastSentence {
        let wordCount = CGFloat(word.count)
        let individualCharacterLength = frame.width / CGFloat(string.count)

        let wordOriginX = frame.minX + individualCharacterLength * CGFloat(index)
        let wordWidth = individualCharacterLength * wordCount
        let wordFrame = CGRect(x: wordOriginX, y: frame.minY, width: wordWidth, height: frame.height)

        let word = FastSentence(
            string: word,
            frame: wordFrame
        )

        return word
    }
}

struct Sentence {
    var string: String

    var confidence: Double

    /// normalized points from `0` to `1`
    var topLeft: CGPoint
    var topRight: CGPoint
    var bottomRight: CGPoint
    var bottomLeft: CGPoint

    func getPosition(for range: Range<Int>) -> ScannedPosition {
        /// width, height, and center for the entire sentence
        let sentenceWidth = CGPointDistance(from: topLeft, to: topRight)
        let sentenceHeight = CGPointDistance(from: topLeft, to: bottomLeft)
        let sentenceCenter = CGPoint(
            x: (topRight.x - bottomLeft.x) / 2,
            y: (topRight.y - bottomLeft.y) / 2
        )
        let sentenceFrame = CGRect(
            x: sentenceCenter.x - sentenceWidth / 2,
            y: sentenceCenter.y - sentenceHeight / 2,
            width: sentenceWidth,
            height: sentenceHeight
        )

        let characterLength = sentenceWidth / CGFloat(string.count)

        let highlightXOffset = characterLength * CGFloat(range.lowerBound)
        let highlightWidth = characterLength * CGFloat(range.count)

        /// frame of highlight
        let highlightFrame = CGRect(
            x: sentenceFrame.origin.x + highlightXOffset,
            y: 0,
            width: highlightWidth,
            height: sentenceHeight
        )

        let yDifference = topRight.y - topLeft.y
        let xDifference = topRight.x - topLeft.x
        let angle = atan2(yDifference, xDifference)

        let position = ScannedPosition(
            pivotPoint: sentenceCenter,
            center: highlightFrame.center,
            size: highlightFrame.size,
            angle: angle
        )

        return position
    }
}
