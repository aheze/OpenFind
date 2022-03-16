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
        var visionOptions = VisionOptions()
        visionOptions.orientation = .right
        visionOptions.level = .fast
        visionOptions.customWords = searchViewModel.customWords
        
        var findOptions = FindOptions()
        findOptions.priority = .cancelIfBusy
        findOptions.action = .camera

        /// `nil` if was finding before
        let request = await Find.find(in: .pixelBuffer(pixelBuffer), visionOptions: visionOptions, findOptions: findOptions)
        let sentences = Find.getFastSentences(from: request)
        let highlights = sentences.getHighlights(stringToGradients: searchViewModel.stringToGradients)

        DispatchQueue.main.async {
            self.highlightsViewModel.update(with: highlights, replace: false)
            self.createLivePreviewEvent(sentences: sentences, highlights: highlights)
            self.checkEvents()
        }
    }

    /// use accurate mode and wait
    func findAndAddHighlights(image: CGImage, replace: Bool = false, wait: Bool) async -> [Sentence] {
        var visionOptions = VisionOptions()
        visionOptions.orientation = .up
        visionOptions.level = .accurate
        visionOptions.customWords = searchViewModel.customWords
        
        var findOptions = FindOptions()
        findOptions.priority = .waitUntilNotBusy
        findOptions.action = .camera

        let request = await Find.find(in: .cgImage(image), visionOptions: visionOptions, findOptions: findOptions)
        let sentences = Find.getSentences(from: request)
        let highlights = sentences.getHighlights(stringToGradients: searchViewModel.stringToGradients)
        DispatchQueue.main.async {
            self.highlightsViewModel.update(with: highlights, replace: replace)
        }
        return sentences
    }
}
