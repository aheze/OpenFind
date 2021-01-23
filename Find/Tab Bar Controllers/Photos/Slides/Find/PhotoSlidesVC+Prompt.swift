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
    func changePromptToStarting() {
        slideFindBar?.hasPrompt = false
        animatePromptReveal(reveal: false)
    }
    
    func animatePromptReveal(reveal: Bool = true) {
        print("aimate reveal!!")
        slideFindBar?.layoutIfNeeded()
        if reveal {
            let promptHeight = slideFindBar?.promptLabel.bounds.height ?? 0
            
            slideFindBar?.blurViewHeightC.constant = 45 + promptHeight + 16
            
            UIView.animate(withDuration: 0.2) {
                self.slideFindBar?.layoutIfNeeded()
                self.slideFindBar?.promptLabel.alpha = 1
            }
        } else {
            slideFindBar?.blurViewHeightC.constant = 45
            
            UIView.animate(withDuration: 0.2) {
                self.slideFindBar?.layoutIfNeeded()
                self.slideFindBar?.promptLabel.alpha = 0
            }
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
        let toFindFromPhotos = " to find with OCR.".set(style: textStyle)
        
        let nextButtonAttachment = AttributedString(image: Image(named: "ContinueButton"), bounds: "0,-6,76,24")
        
        let attributedText = "\(howMany)".set(style: textStyle) + resultsInCache + nextButtonAttachment! + toFindFromPhotos
        slideFindBar?.promptLabel.attributedText = attributedText
        slideFindBar?.hasPrompt = true
        animatePromptReveal()
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
        animatePromptReveal()
    }
    
    func setPromptToFastFinding() { /// currently fast finding
        print("set to fast")
        let textStyle = Style {
            $0.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            $0.color = UIColor.secondaryLabel
        }
        
        let attributedText = "Finding with OCR...".set(style: textStyle)
        slideFindBar?.promptLabel.attributedText = attributedText
        slideFindBar?.hasPrompt = true
        animatePromptReveal()
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
        animatePromptReveal()
    }
}
