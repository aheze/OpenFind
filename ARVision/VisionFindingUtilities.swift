//
//  VisionFindingUtilities.swift
//  ARVision
//
//  Created by Zheng on 11/28/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import Vision

struct VisionFindingUtilities {
    static func getMiddleWordBoundingBox(textObservation: VNRecognizedTextObservation) -> CGRect {
        guard let text = textObservation.topCandidates(1).first?.string else { return textObservation.boundingBox}
        let separatedWords = text.components(separatedBy: " ")
        let middleWordIndex = separatedWords.middleIndex
        let middleWord = separatedWords[safe: middleWordIndex]
        
        let middleWordStartingCharacters = separatedWords.prefix(middleWordIndex).joined(separator: "")
        
        let wordPercentageOfTotal = Double(middleWord?.count ?? text.count) / Double(text.count)
        let startingCharactersPercentageOfTotal = Double(middleWordStartingCharacters.count) / Double(text.count)
        
        let wordWidth = textObservation.boundingBox.width * wordPercentageOfTotal
        let wordXOriginOffset = textObservation.boundingBox.width * startingCharactersPercentageOfTotal
        
        var wordBoundingBox = textObservation.boundingBox
        wordBoundingBox.size.width = wordWidth
        wordBoundingBox.origin.x += wordXOriginOffset
        return wordBoundingBox
        
    }
    static func getWordBoundingBox(textObservation: VNRecognizedTextObservation, firstWord: Bool) -> CGRect {
        let text = textObservation.topCandidates(1).first?.string
        if firstWord {
            
            let wordCount = text?.components(separatedBy: " ").first?.count ?? 1
            let wordPercentageOfTotal = Double(wordCount) / Double(text?.count ?? 1)
            let wordWidth = textObservation.boundingBox.width * wordPercentageOfTotal
            var wordBoundingBox = textObservation.boundingBox
            wordBoundingBox.size.width = wordWidth
            return wordBoundingBox
        } else {
            
            let wordCount = text?.components(separatedBy: " ").last?.count ?? 1
            let wordPercentageOfTotal = Double(wordCount) / Double(text?.count ?? 1)
            let wordWidth = textObservation.boundingBox.width * wordPercentageOfTotal
            let wordXOriginOffset = textObservation.boundingBox.width - wordWidth
            
            var wordBoundingBox = textObservation.boundingBox
            wordBoundingBox.size.width = wordWidth
            wordBoundingBox.origin.x += wordXOriginOffset
            return wordBoundingBox
        }
        
    }
}
