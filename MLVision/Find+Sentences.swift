//
//  Find+Sentences.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit
import Vision

/**
 Get the sentences from a VNRequest
 */

extension Find {
    static func getFastSentences(from request: VNRequest) -> [FastSentence] {
        guard let results = request.results else { return [] }

        var sentences = [FastSentence]()
        for case let observation as VNRecognizedTextObservation in results {
            guard let text = observation.topCandidates(1).first else { continue }
            let string = text.string
            let frame = observation.boundingBox.normalizeVisionRect()
            let sentence = FastSentence(string: string, frame: frame)
            sentences.append(sentence)
        }
        
        return sentences
    }
    static func getSentences(from request: VNRequest) -> [Sentence] {
        guard let results = request.results else { return [] }

        var sentences = [Sentence]()
        for case let observation as VNRecognizedTextObservation in results {
            guard let text = observation.topCandidates(1).first else { continue }

            let ranges = text.string.ranges()

            do {
                var rawComponents = [Sentence.Component]()
                for range in ranges {
                    let start = text.string.index(text.string.startIndex, offsetBy: range.lowerBound)
                    let end = text.string.index(text.string.startIndex, offsetBy: range.upperBound)
                    guard let rectangleObservation = try text.boundingBox(for: start ..< end) else { continue }
                    let component = Sentence.Component(
                        range: range,
                        frame: rectangleObservation.getFrame()
                    )
                    rawComponents.append(component)
                }

                /// Sometimes Vision returns 1 huge bounding box for multiple words.
                /// In this case, adjust the `components` for keys that encompass all the words.
                var cleanedComponents = [Sentence.Component]()
                for component in rawComponents {
                    let existingComponentIndex = cleanedComponents.firstIndex {
                        /// Sometimes they are very close, so need to check the difference instead of directly using `==`
                        abs($0.frame.origin.x - component.frame.origin.x) < 0.00001
                    }
                    if let existingComponentIndex = existingComponentIndex {
                        /// must combine together
                        let initialRange = rawComponents[existingComponentIndex].range
                        let otherRange = component.range

                        /// take the lowest and highest for a combined word
                        // 1..<3 and 10..<20 -> 1..<20
                        // 1..<4 and 2..<10 -> 1 -> 10
                        let lowerBound = min(initialRange.lowerBound, otherRange.lowerBound)
                        let upperBound = max(initialRange.upperBound, otherRange.upperBound)
                        let newRange = lowerBound ..< upperBound

                        cleanedComponents[existingComponentIndex].range = newRange
                    } else {
                        cleanedComponents.append(component)
                    }
                }

                let sentence = Sentence(
                    string: text.string,
                    components: cleanedComponents,
                    confidence: Double(text.confidence)
                )
                sentences.append(sentence)
            } catch {
                Debug.log("Error: \(error)")
            }
        }

        return sentences
    }
}
