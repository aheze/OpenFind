//
//  Find+Utilities.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/30/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//

import UIKit
import VideoToolbox
import Vision

extension VNRectangleObservation {
    func getFrame() -> CGRect {
        let frame = boundingBox.normalizeVisionRect()
        return frame
    }
}

extension CGRect {
    func normalizeVisionRect() -> CGRect {
        var frame = self
        frame.origin.y = 1 - frame.origin.y - frame.height /// get top-left
        return frame
    }
}

extension CVPixelBuffer {
    /// Returns a Core Graphics image from the pixel buffer's current contents.
    func toCGImage() -> CGImage? {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(self, options: nil, imageOut: &cgImage)
        return cgImage
    }
}
