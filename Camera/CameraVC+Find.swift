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
        
        Find.run(in: .pixelBuffer(pixelBuffer)) { [weak self] sentences in
            guard let self = self else { return }
            
            var highlights = Set<Highlight>()
            for sentence in sentences {
                for (string, gradient) in self.searchViewModel.stringToGradients {
                    let indices = sentence.string.lowercased().indicesOf(string: string.lowercased())
                    for index in indices {
                        let word = sentence.getWord(word: string, at: index)
                        
                        let highlight = Highlight(
                            string: string,
                            frame: word.frame.scaleTo(self.view.bounds.size),
                            colors: [UIColor(hex: 0xff2600)]
                        )
                        
                        highlights.insert(highlight)
                        
                    }
                }
                
//                for value in self.searchViewModel.values {
//                    switch value {
//                    case .string(_):
//                        <#code#>
//                    case .list(_):
//                        <#code#>
//                    case .addNew(_):
//                        <#code#>
//                    }
//                }
                
//                let indices = sentence.string.lowercased().indicesOf(string: self.textToFind.lowercased())
//                for index in indices {
//                    let word = sentence.getWord(word: self.textToFind, at: index)
//
//                    let highlight = Highlight(
//                        string: self.textToFind,
//                        frame: word.frame.scaleTo(self.highlightsView.bounds.size),
//                        colors: [UIColor(hex: 0xff2600)]
//                    )
//
//                    highlights.insert(highlight)
//
//                }
            }
            
//            self.highlightsViewModel.update(with: highlights)
        }
    }
}
