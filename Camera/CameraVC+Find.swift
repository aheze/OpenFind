//
//  CameraVC+Find.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/30/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//

import AVFoundation
import Popovers
import SwiftUI
import UIKit

struct PopoverView: View {
    let image: UIImage
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .background(Color.white)
            .cornerRadius(16)
            .popoverShadow()
            .frame(width: 150, height: 150)
    }
}

extension CameraViewController {
    /// use fast mode
    func findAndAddHighlights(pixelBuffer: CVPixelBuffer) async {
        var visionOptions = VisionOptions()

        visionOptions.orientation = await UIWindow.interfaceOrientation?.getVisionOrientation() ?? .right
        visionOptions.level = .fast
        visionOptions.customWords = searchViewModel.customWords

        count += 1
        if count >= 40 {
            count = 0
            DispatchQueue.main.async {
                if let popover = self.view.popover(tagged: "Popover") {
                    popover.dismiss()
                }

                if let cgImage = pixelBuffer.toCGImage() {
                    let uiImage = UIImage(cgImage: cgImage)
                    var attributes = Popover.Attributes()
                    attributes.tag = "Popover"
                    attributes.position = .relative(popoverAnchors: [.topRight])
                    attributes.dismissal.mode = .none
                    attributes.sourceFrame = { [weak self] in
                        guard let self = self else { return .zero }
                        let rect = self.view.bounds.insetBy(dx: 20, dy: 120)
                        return rect
                    }
                    let popover = Popover(attributes: attributes) {
                        PopoverView(image: uiImage)
                    }
                    self.present(popover)
                }
            }
        }
        var findOptions = FindOptions()
        findOptions.priority = .cancelIfBusy
        findOptions.action = .camera

        /// `nil` if was finding before
        let request = await Find.find(in: .pixelBuffer(pixelBuffer), visionOptions: visionOptions, findOptions: findOptions)
        let sentences = Find.getFastSentences(from: request)
        let highlights = sentences.getHighlights(stringToGradients: searchViewModel.stringToGradients)

        if count % 10 == 0 {
            print("-> \(sentences.map { $0.string })")
        }
        
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
