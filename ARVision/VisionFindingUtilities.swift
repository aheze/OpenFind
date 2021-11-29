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
