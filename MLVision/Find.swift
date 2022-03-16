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
            print("Started: \(startTime)")
            if startTime == nil {
                continueQueue()
            }
        }
    }

    static var prioritizedAction: FindOptions.Action? {
        didSet {
            continueQueue()
        }
    }

    /// latest are first priority
    static var queuedRuns = [QueuedRun]()

    static func find(in image: FindImage, visionOptions: VisionOptions = VisionOptions(), findOptions: FindOptions) async -> VNRequest {
        if findOptions.priority == .waitUntilNotBusy, startTime != nil {
            return await withCheckedContinuation { continuation in
                let queuedRun = QueuedRun(image: image, visionOptions: visionOptions, findOptions: findOptions) { request in
                    continuation.resume(returning: request)
                }
                queuedRuns.append(queuedRun)
            }
        } else {
            guard startTime == nil else { return VNRequest() }
            startTime = Date()
            let sentences = await run(in: image, visionOptions: visionOptions, findOptions: findOptions)
            startTime = nil
            return sentences
        }
    }

    /// run Vision
    internal static func run(in image: FindImage, visionOptions: VisionOptions, findOptions: FindOptions) async -> VNRequest {
        return await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { request, _ in
                continuation.resume(returning: request)
            }

            request.customWords = visionOptions.customWords
            request.recognitionLevel = visionOptions.level

            let imageRequestHandler: VNImageRequestHandler
            switch image {
            case .cgImage(let image):
                imageRequestHandler = VNImageRequestHandler(cgImage: image, orientation: visionOptions.orientation)
            case .pixelBuffer(let pixelBuffer):
                imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: visionOptions.orientation)
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
