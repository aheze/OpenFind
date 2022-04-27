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
        let width = CGPointDistance(from: topLeft, to: topRight)
        let height = CGPointDistance(from: topLeft, to: bottomLeft)
        let size = CGSize(width: width, height: height)
        let center = CGPoint(
            x: topRight.x - bott,
            y: <#T##CGFloat#>
        )
        
        let characterLength = width / CGFloat(string.count)
        let characterXOffset = gridWidth * CGFloat(range.lowerBound)

        let frame = CGRect(
            x: component.frame.origin.x + characterXOffset,
            y: component.frame.origin.y,
            width: characterLength,
            height: component.frame.height
        )
        
        
        let yDifference = topRight.y - topLeft.y
        let xDifference = topRight.x - topLeft.x
        let angle = atan2(yDifference, xDifference)
        
        let position = ScannedPosition(
            pivotPoint: <#T##CGPoint#>,
            center: <#T##CGPoint#>,
            size: size,
            angle: angle
        )
    }
}
