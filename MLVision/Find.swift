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

    /// run Vision
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
                }
            }
        }
    }
}

extension Find {
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

                let sentence = Sentence(string: text.string, components: cleanedComponents)
                sentences.append(sentence)
            } catch {
                Global.log("Error: \(error)")
            }
        }

        return sentences
    }
}
