//
//  VisionUtilities.swift
//  ARVision
//
//  Created by Zheng on 11/24/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import VideoToolbox

extension CGImage {
    /**
     Creates a new CGImage from a CVPixelBuffer.
     - Note: Not all CVPixelBuffer pixel formats support conversion into a
     CGImage-compatible pixel format.
     */
    static func create(pixelBuffer: CVPixelBuffer) -> CGImage? {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
        return cgImage
    }
}

extension UIImage {
    convenience init?(pixelBuffer: CVPixelBuffer) {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)

        guard let cgImage = cgImage else {
            return nil
        }

        self.init(cgImage: cgImage)
    }
}

extension Optional where Wrapped == Date {
    func isPastCoolDown(_ coolDownPeriod: CGFloat) -> Bool {
        if let self = self {
            return abs(self.timeIntervalSinceNow) > coolDownPeriod
        } else {
            return true
        }
    }
}

/// https://stackoverflow.com/a/56876898/14351818
extension Array {
    var middleIndex: Int {
        return (isEmpty ? startIndex : count - 1) / 2
    }
}
