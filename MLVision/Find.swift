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

    static func find(in image: FindImage, options: FindOptions = FindOptions(), action: FindingAction, wait: Bool) async -> VNRequest {
        if wait, startTime != nil {
            return await withCheckedContinuation { continuation in
                let queuedRun = QueuedRun(image: image, options: options, action: action) { request in
                    continuation.resume(returning: request)
                }
                queuedRuns.append(queuedRun)
            }
        } else {
            guard startTime == nil else { return VNRequest() }
            startTime = Date()
            let sentences = await run(in: image, options: options)
            startTime = nil
            return sentences
        }
    }

    /// run Vision
    internal static func run(in image: FindImage, options: FindOptions = FindOptions()) async -> VNRequest {
        return await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { request, _ in
                continuation.resume(returning: request)
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
