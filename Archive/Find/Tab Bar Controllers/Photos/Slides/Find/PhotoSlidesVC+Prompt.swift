//
//  PhotoSlidesVC+Prompt.swift
//  Find
//
//  Created by Zheng on 1/22/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftRichString
import UIKit

extension PhotoSlidesViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        pressedContinue()
        slideFindBar?.findBar.searchField.resignFirstResponder()
        return true
    }
}

extension PhotoSlidesViewController {
    func changePromptToStarting() {
        slideFindBar?.hasPrompt = false
        animatePromptReveal(reveal: false)
    }
    
    func animatePromptReveal(reveal: Bool = true) {
        slideFindBar?.layoutIfNeeded()
        if reveal {
            let promptHeight = slideFindBar?.promptTextView.bounds.height ?? 0
            
            slideFindBar?.blurViewHeightC.constant = 45 + promptHeight + 16
            
            UIView.animate(withDuration: 0.2) {
                self.slideFindBar?.layoutIfNeeded()
                self.slideFindBar?.promptBackgroundView.alpha = 1
            }
        } else {
            slideFindBar?.blurViewHeightC.constant = 45
            
            UIView.animate(withDuration: 0.2) {
                self.slideFindBar?.layoutIfNeeded()
                self.slideFindBar?.promptBackgroundView.alpha = 0
            }
        }
    }
    
    /// photo is cached
    func setPromptToHowManyCacheResults(howMany: Int) {
        continueButtonVisible = true
       
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
        let resultsInCache = "\(spaceOrUnit)\(results)\(inCache)"
        let toFindFromPhotos = toFindWithOCR
        
        let nextButtonAttachment = AttributedString(image: Image(named: "ContinueButton"), bounds: "0,-6,76,24")
        
        let attributedText = "\(howMany)".set(style: textStyle) + resultsInCache.set(style: textStyle) + nextButtonAttachment! + toFindFromPhotos.set(style: textStyle)
        slideFindBar?.promptTextView.attributedText = attributedText
        slideFindBar?.hasPrompt = true
        animatePromptReveal()
        
        slideFindBar?.promptBackgroundView.accessibilityValue = "\(howMany)" + resultsInCache + "Continue/Return button on the keyboard, or double-tap this label, " + toFindFromPhotos
        
        let summaryTitle = AccessibilityText(text: "Summary status:\n", isRaised: true)
        let summaryString = AccessibilityText(text: "\(howMany)" + resultsInCache + "Continue/Return button on the keyboard, or double-tap Summary label, " + toFindFromPhotos, isRaised: false)
        postAnnouncement([summaryTitle, summaryString])
    }
    
    /// photo is not cached
    func setPromptToContinue() {
        continueButtonVisible = true
        
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
        
        slideFindBar?.promptTextView.attributedText = attributedText
        slideFindBar?.hasPrompt = true
        animatePromptReveal()
        
        slideFindBar?.promptBackgroundView.accessibilityValue = pressText + "Continue/Return button on the keyboard, or double-tap this label, " + toFindWithOCR
        
        let summaryTitle = AccessibilityText(text: "Summary status:\n", isRaised: true)
        let summaryString = AccessibilityText(text: pressText + "Continue/Return button on the keyboard, or double-tap Summary label, " + toFindWithOCR, isRaised: false)
        postAnnouncement([summaryTitle, summaryString])
    }
    
    func setPromptToFastFinding() { /// currently fast finding
        continueButtonVisible = false
        
        let textStyle = Style {
            $0.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            $0.color = UIColor.secondaryLabel
        }
        
        let findingWithOCR = NSLocalizedString("findingWithOCR", comment: "")
        
        let attributedText = findingWithOCR.set(style: textStyle)
        slideFindBar?.promptTextView.attributedText = attributedText
        slideFindBar?.hasPrompt = true
        animatePromptReveal()
        
        slideFindBar?.promptBackgroundView.accessibilityValue = findingWithOCR
        
        let summaryTitle = AccessibilityText(text: "Summary status:\n", isRaised: true)
        let summaryString = AccessibilityText(text: findingWithOCR, isRaised: false)
        postAnnouncement([summaryTitle, summaryString])
    }
    
    /// Finished searching cache and uncached photos
    func setPromptToFinishedFastFinding(howMany: Int) {
        continueButtonVisible = false
        
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
        slideFindBar?.promptTextView.attributedText = attributedText
        slideFindBar?.hasPrompt = true
        animatePromptReveal()
        
        slideFindBar?.promptBackgroundView.accessibilityValue = "Completed finding. " + "\(howMany)" + results
        
        let summaryTitle = AccessibilityText(text: "Summary status:\n", isRaised: true)
        let summaryString = AccessibilityText(text: "Completed finding. " + "\(howMany)" + results, isRaised: false)
        postAnnouncement([summaryTitle, summaryString])
    }
    
    func postAnnouncement(_ accessibilityText: [AccessibilityText]) {
        if findPressed {
            UIAccessibility.postAnnouncement(accessibilityText)
        }
    }
}
