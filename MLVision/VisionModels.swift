//
//  VisionModels.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit
import Vision

struct VisionOptions {
    var level = VNRequestTextRecognitionLevel.fast
    var customWords = [String]()
    var orientation = CGImagePropertyOrientation.up
    var recognitionLanguages = [Settings.Values.RecognitionLanguage.english.rawValue]

    /// return nothing if empty
    func getCustomWords() -> [String]? {
        if customWords.isEmpty {
            return nil
        } else {
            return customWords
        }
    }

    func getRecognitionLanguages() -> [String] {
        print("rec nefore: \(recognitionLanguages)")
        let recognitionLanguages = recognitionLanguages.filter {
            if let language = Settings.Values.RecognitionLanguage(rawValue: $0) {
                let available = language.isAvailableFor(
                    accurateMode: level == .accurate,
                    version: Utilities.deviceVersion()
                )
                return available
            }
            return false
        }
        print("rec AFTER: \(recognitionLanguages)")
        if recognitionLanguages.isEmpty {
            return [Settings.Values.RecognitionLanguage.english.rawValue]
        } else {
            return recognitionLanguages
        }
    }
}

struct FindOptions {
    var priority = Priority.cancelIfBusy
    var action = Action.camera

    enum Priority {
        /// `startASAP` is for photos scanning. As soon as the current scanning photo is done, go.
//        case startASAP

        /// As soon as the current scanning photo is done, start.
        case waitUntilNotBusy
        case cancelIfBusy /// if `startTime` is nil, don't even start. Returns
    }

    enum Action {
        case camera
        case photosScanning /// photos scanning
        case individualPhoto
    }
}

enum FindError: Error {
    case startTimeExistedWasBusy
}

enum FindImage: Equatable {
    case cgImage(CGImage)
    case pixelBuffer(CVPixelBuffer)
}

struct QueuedRun {
    var image: FindImage
    var visionOptions: VisionOptions
    var findOptions: FindOptions
    var completion: ((VNRequest) -> ())?
}
