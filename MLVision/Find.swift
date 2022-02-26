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

struct FindOptions {
    var level = VNRequestTextRecognitionLevel.fast
    var customWords = [String]()
    var orientation = CGImagePropertyOrientation.up
}

enum FindImage {
    case cgImage(CGImage)
    case pixelBuffer(CVPixelBuffer)
}

enum FindingAction {
    case camera
    case photos /// photos scanning
}

struct QueuedRun {
    var image: FindImage
    var options: FindOptions
    var action: FindingAction
    var completion: (([Sentence]) -> ())?
}

enum Find {
    static var startTime: Date? {
        didSet {
            continueQueue()
        }
    }

    static var prioritizedAction: FindingAction? {
        didSet {
            continueQueue()
        }
    }

    static var queuedRuns = [QueuedRun]()

    static func find(in image: FindImage, options: FindOptions = FindOptions(), action: FindingAction, wait: Bool) async -> [Sentence]? {
        if wait, startTime != nil {
            return await withCheckedContinuation { continuation in
                let queuedRun = QueuedRun(image: image, options: options, action: action) { sentences in
                    continuation.resume(returning: sentences)
                }
                queuedRuns.append(queuedRun)
            }
        } else {
            guard startTime == nil else { return nil }
            startTime = Date()
            let sentences = await run(in: image, options: options)
            startTime = nil
            return sentences
        }
    }

    internal static func run(in image: FindImage, options: FindOptions = FindOptions()) async -> [Sentence] {
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

            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    try imageRequestHandler.perform([request])
                } catch {
                    Global.log("Error finding: \(error)", .error)
//                    continuation.resume(returning: [])
                }
            }
        }
    }
}

extension Find {
    static func getSentences(from request: VNRequest) -> [Sentence] {
        guard
            let results = request.results
        else {
            return []
        }

        var sentences = [Sentence]()
        for case let observation as VNRecognizedTextObservation in results {
            guard let text = observation.topCandidates(1).first else { continue }
//            text.boundingBox(for: <#T##Range<String.Index>#>)
            var boundingBox = observation.boundingBox
            boundingBox.origin.y = 1 - boundingBox.minY - boundingBox.height

            let sentence = Sentence(
                string: text.string,
                frame: boundingBox,
                confidence: CGFloat(text.confidence)
            )
            sentences.append(sentence)
        }

        return sentences
    }
}
