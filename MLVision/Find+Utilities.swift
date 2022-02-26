//
//  Find+Utilities.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/30/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//
    

import UIKit

extension Sentence {
    
    /// If self is a sentence
    func getWord(word: String, at index: Int) -> Sentence {
        let wordCount = CGFloat(word.count)
        let individualCharacterLength = self.frame.width / CGFloat(self.string.count)
        
        let wordOriginX = self.frame.minX + individualCharacterLength * CGFloat(index)
        let wordWidth = individualCharacterLength * wordCount
        let wordFrame = CGRect(x: wordOriginX, y: self.frame.minY, width: wordWidth, height: self.frame.height)
        
        let word = Sentence(
            string: word,
            frame: wordFrame,
            confidence: self.confidence
        )
        
        return word
    }
}

extension CGRect {
    func getNormalizedRectFromVision() -> CGRect {
        var rect = self
        rect.origin.y = 1 - rect.minY - rect.height
        return rect
    }
}

extension String {
    func indicesOf(string: String) -> [Int] {
        var indices = [Int]()
        var searchStartIndex = startIndex
        
        while searchStartIndex < endIndex,
              let range = range(of: string, range: searchStartIndex..<endIndex),
              !range.isEmpty
        {
            let index = distance(from: startIndex, to: range.lowerBound)
            indices.append(index)
            searchStartIndex = range.upperBound
        }
        
        return indices
    }
}
