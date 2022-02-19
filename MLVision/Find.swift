//
//  Find.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/30/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//

import AVFoundation
import UIKit
import Vision

struct FindText {
    var string: String
    var frame: CGRect
    var confidence: CGFloat
}

struct FindOptions {
    var level = VNRequestTextRecognitionLevel.fast
    var customWords = [String]()
    var orientation = CGImagePropertyOrientation.up
}

enum FindImage {
    case cgImage(CGImage)
    case pixelBuffer(CVPixelBuffer)
}

enum Find {
    static var startTime: Date?

    static func run(in image: FindImage, options: FindOptions = FindOptions()) async -> [FindText] {
        print("Setting start time.")
        startTime = Date()
        
        return await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { request, _ in
                let sentences = getSentences(from: request)
                continuation.resume(returning: sentences)
            }

            request.customWords = options.customWords
            request.recognitionLevel = options.level

            let imageRequestHandler: VNImageRequestHandler
            switch image {
            case .cgImage(let image):
                imageRequestHandler = VNImageRequestHandler(cgImage: image, orientation: options.orientation)
            case .pixelBuffer(let pixelBuffer):
                imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: options.orientation)
            }

            do {
                try imageRequestHandler.perform([request])
            } catch {
                print("Error finding: \(error)")
            }
        }
    }
}

extension Find {
    static func getSentences(from request: VNRequest) -> [FindText] {
        startTime = nil
        guard
            let results = request.results
        else {
            return []
        }

        var sentences = [FindText]()
        for case let observation as VNRecognizedTextObservation in results {
            guard let text = observation.topCandidates(1).first else { continue }
            var boundingBox = observation.boundingBox
            boundingBox.origin.y = 1 - boundingBox.minY - boundingBox.height

            let sentence = FindText(
                string: text.string,
                frame: boundingBox,
                confidence: CGFloat(text.confidence)
            )
            sentences.append(sentence)
        }

        return sentences
    }
}
