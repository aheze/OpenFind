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
        
        let resultsText = NSLocalizedString("resultsText", comment: "")
        let resultText = NSLocalizedString("resultText", comment: "")
        let inCache = NSLocalizedString("_InCache", comment: "")
        let toFindWithOCR = NSLocalizedString("toFindWithOCR", comment: "")
        
        
        var results = resultsText
        if howMany == 1 {
            results = resultText
        }
        
        let spaceOrUnit = NSLocalizedString("spaceOrUnit", comment: "")
        let resultsInCache = "\(spaceOrUnit)\(results)\(inCache)".set(style: textStyle)
        let toFindFromPhotos = toFindWithOCR.set(style: textStyle)
        
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
        
        let pressText = NSLocalizedString("pressText", comment: "")
        let toFindWithOCR = NSLocalizedString("toFindWithOCR", comment: "")
        
        let press = pressText.set(style: textStyle)
        let toFindFromPhotos = toFindWithOCR.set(style: textStyle)
        
        let nextButtonAttachment = AttributedString(image: Image(named: "ContinueButton"), bounds: "0,-6,76,24")
        
        let attributedText = press.set(style: textStyle) + nextButtonAttachment! + toFindFromPhotos
        
        slideFindBar?.promptLabel.attributedText = attributedText
        slideFindBar?.hasPrompt = true
        animatePromptReveal()
    }
    
    func setPromptToFastFinding() { /// currently fast finding
        let textStyle = Style {
            $0.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            $0.color = UIColor.secondaryLabel
        }
        
        let findingWithOCR = NSLocalizedString("findingWithOCR", comment: "")
        
        let attributedText = findingWithOCR.set(style: textStyle)
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
        
        let resultsText = NSLocalizedString("resultsText", comment: "")
        let resultText = NSLocalizedString("resultText", comment: "")
        let spaceOrUnit = NSLocalizedString("spaceOrUnit", comment: "")
        
        var results = resultsText
        if howMany == 1 {
            results = resultText
        }
        
        let attributedText = "\(howMany)\(spaceOrUnit)\(results)".set(style: textStyle)
        slideFindBar?.promptLabel.attributedText = attributedText
        slideFindBar?.hasPrompt = true
        animatePromptReveal()
    }
}
