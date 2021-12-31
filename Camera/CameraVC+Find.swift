//
//  CameraVC+Find.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/30/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//


import UIKit
import AVFoundation

extension CameraViewController {
    func find(in pixelBuffer: CVPixelBuffer) {
        guard Find.startTime == nil else { return }
        
        var options = FindOptions()
        options.orientation = .right
        
        Find.run(in: .pixelBuffer(pixelBuffer), options: options) { [weak self] sentences in
            guard let self = self else { return }
            
            var highlights = Set<Highlight>()
            for sentence in sentences {
                for (string, gradient) in self.searchViewModel.stringToGradients {
                    let indices = sentence.string.lowercased().indicesOf(string: string.lowercased())
                    for index in indices {
                        let word = sentence.getWord(word: string, at: index)
                        
                        let highlight = Highlight(
                            string: string,
                            frame: word.frame.scaleTo(self.drawingViewSize),
                            colors: [UIColor(hex: 0x00aeef)]
                        )
                        
                        highlights.insert(highlight)
                        
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.highlightsViewModel.update(with: highlights)
            }
        }
    }
}
