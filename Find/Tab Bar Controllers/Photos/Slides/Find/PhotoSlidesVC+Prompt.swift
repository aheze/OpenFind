//
//  PhotoSlidesVC+Prompt.swift
//  Find
//
//  Created by Zheng on 1/22/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import SwiftRichString

//    blurViewHeightC
extension PhotoSlidesViewController {
    func changePromptToStarting(startingFilter: PhotoFilter, howManyPhotos: Int, isAllPhotos: Bool) {
        slideFindBar?.hasPrompt = false
        UIView.animate(withDuration: 0.2) {
            self.slideFindBar?.promptLabel.alpha = 0
        }
    }
    
    /// photo is cached
    func setPromptToHowManyCacheResults(howMany: Int) {
        let textStyle = Style {
            $0.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            $0.color = UIColor.secondaryLabel
        }
        
        var results = "results"
        if howMany == 1 {
            results = "result"
        }
        
        let resultsInCache = " \(results) in cache. Press ".set(style: textStyle)
        let toFindFromPhotos = " to find with OCR again.".set(style: textStyle)
        
        let nextButtonAttachment = AttributedString(image: Image(named: "ContinueButton"), bounds: "0,-6,76,24")
        
        let attributedText = "\(howMany)".set(style: textStyle) + resultsInCache + nextButtonAttachment! + toFindFromPhotos
        slideFindBar?.promptLabel.attributedText = attributedText
        slideFindBar?.hasPrompt = true
    }
    
    /// photo is not cached
    func setPromptToContinue() {
        let textStyle = Style {
            $0.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            $0.color = UIColor.secondaryLabel
        }
        
        let press = "Press ".set(style: textStyle)
        let toFindFromPhotos = " to find with OCR".set(style: textStyle)
        
        let nextButtonAttachment = AttributedString(image: Image(named: "ContinueButton"), bounds: "0,-6,76,24")
        
        let attributedText = press.set(style: textStyle) + nextButtonAttachment! + toFindFromPhotos
        
        slideFindBar?.promptLabel.attributedText = attributedText
        slideFindBar?.hasPrompt = true
    }
    
    func setPromptToFastFinding() { /// currently fast finding
        let textStyle = Style {
            $0.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            $0.color = UIColor.secondaryLabel
        }
        
        let attributedText = "Finding with OCR...".set(style: textStyle)
        slideFindBar?.promptLabel.attributedText = attributedText
        slideFindBar?.hasPrompt = true
    }
    
    /// Finished searching cache and uncached photos
    func setPromptToFinishedFastFinding(howMany: Int) {
        let textStyle = Style {
            $0.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            $0.color = UIColor.secondaryLabel
        }
        
        var results = "results"
        if howMany == 1 {
            results = "result"
        }
        
        let attributedText = "\(howMany) \(results)".set(style: textStyle)
        slideFindBar?.promptLabel.attributedText = attributedText
        slideFindBar?.hasPrompt = true
    }
}
