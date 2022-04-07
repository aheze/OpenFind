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

extension StringProtocol {
    /// a range of Ints that represent each word in the string
    func ranges() -> [Range<Int>] {
        var ranges = [Range<Int>]()
        enumerateSubstrings(in: startIndex..., options: .byWords) { component, _, range, _ in
            let start = distance(to: range.lowerBound)
            let end = distance(to: range.upperBound)
            ranges.append(start ..< end)
        }
        return ranges
    }
}

extension Collection {
    func distance(to index: Index) -> Int { distance(from: startIndex, to: index) }
}

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

extension UIInterfaceOrientation {
    func getVisionOrientation() -> CGImagePropertyOrientation {
//        return .up
        switch self {
        case .portrait:
            print("right")
            return .right
        case .landscapeRight: /// home button right
            print("landscapeRight -> up")
            return .up
        case .landscapeLeft: /// home button left
            print("landscapeLeft -> down")
            return .down
        case .portraitUpsideDown:
            print("portraitUpsideDown -> left")
            return .left
        default:
            print("default.")
            return .right
        }
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
