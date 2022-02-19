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
    func findAndAddHighlights(pixelBuffer: CVPixelBuffer) async -> [FindText] {
        var options = FindOptions()
        options.orientation = .right
        options.customWords = searchViewModel.customWords

        let sentences = await find(in: .pixelBuffer(pixelBuffer), options: options)
        addHighlights(from: sentences, replace: false)
        return sentences
    }

    func findAndAddHighlights(image: CGImage, replace: Bool = false) async -> [FindText] {
        var options = FindOptions()
        options.orientation = .up
        options.level = .accurate
        options.customWords = searchViewModel.customWords

        let sentences = await find(in: .cgImage(image), options: options)
        addHighlights(from: sentences, replace: replace)
        return sentences
    }

    func find(in image: FindImage, options: FindOptions) async -> [FindText] {
        guard Find.startTime == nil else { return [] }
        let sentences = await Find.run(in: image, options: options)
        return sentences
    }
}
