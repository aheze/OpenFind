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

    
}

struct FindOptions {
    var priority = Priority.cancelIfBusy
    var action = Action.camera

    enum Priority {
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
