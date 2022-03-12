//
//  VisionModels.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

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
    var completion: ((VNRequest) -> ())?
}
