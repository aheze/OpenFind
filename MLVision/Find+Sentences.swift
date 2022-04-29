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
            let string = text.string
            let confidence = Double(text.confidence)

            do {
                guard let range = string.range(of: string) else { continue }
                guard let rectangleObservation = try text.boundingBox(for: range) else { continue }
                let sentence = Sentence(
                    string: string,
                    confidence: confidence,
                    topLeft: CGPoint(x: rectangleObservation.topLeft.x, y: 1 - rectangleObservation.topLeft.y),
                    topRight: CGPoint(x: rectangleObservation.topRight.x, y: 1 - rectangleObservation.topRight.y),
                    bottomRight: CGPoint(x: rectangleObservation.bottomRight.x, y: 1 - rectangleObservation.bottomRight.y),
                    bottomLeft: CGPoint(x: rectangleObservation.bottomLeft.x, y: 1 - rectangleObservation.bottomLeft.y)
                )

                sentences.append(sentence)
            } catch {
                Debug.log("Error: \(error)")
            }
        }

        return sentences
    }
}
