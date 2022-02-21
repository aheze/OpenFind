//
//  CameraVC+Find.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/30/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//

import AVFoundation
import UIKit

extension CameraViewController {
    /// use fast mode
    func findAndAddHighlights(pixelBuffer: CVPixelBuffer) async {
        var options = FindOptions()
        options.orientation = .right
        options.level = .fast
        options.customWords = searchViewModel.customWords

        /// `nil` if was finding before
        if let sentences = await Find.find(in: .pixelBuffer(pixelBuffer), options: options, action: .camera, wait: false) {
            addHighlights(from: sentences, replace: false)
        }
    }

    /// use accurate mode and wait
    func findAndAddHighlights(image: CGImage, replace: Bool = false, wait: Bool) async -> [FindText] {
        var options = FindOptions()
        options.orientation = .up
        options.level = .accurate
        options.customWords = searchViewModel.customWords

        if let sentences = await Find.find(in: .cgImage(image), options: options, action: .camera, wait: true) {
            addHighlights(from: sentences, replace: replace)
            return sentences
        }
        
        return []
    }
}
