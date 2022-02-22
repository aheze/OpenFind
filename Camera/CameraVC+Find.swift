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
            let highlights = getHighlights(from: sentences)

            DispatchQueue.main.async {
                self.highlightsViewModel.update(with: highlights, replace: false)
                self.createLivePreviewEvent(sentences: sentences, highlights: highlights)
                self.checkEvents()
            }
        }
    }

    /// use accurate mode and wait
    func findAndAddHighlights(image: CGImage, replace: Bool = false, wait: Bool) async -> [Sentence] {
        var options = FindOptions()
        options.orientation = .up
        options.level = .accurate
        options.customWords = searchViewModel.customWords

        if let sentences = await Find.find(in: .cgImage(image), options: options, action: .camera, wait: true) {
            let highlights = getHighlights(from: sentences)
            DispatchQueue.main.async {
                self.highlightsViewModel.update(with: highlights, replace: replace)
            }
            return sentences
        }

        return []
    }
}
