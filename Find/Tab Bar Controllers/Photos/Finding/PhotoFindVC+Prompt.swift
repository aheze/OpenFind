//
//  PhotoFindVC+Prompt.swift
//  Find
//
//  Created by Zheng on 1/17/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import SwiftRichString

extension PhotoFindViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        continuePressed()
        return true
    }
    
    func continuePressed(dismissKeyboard: Bool = true) {
        pressedContinue()
        
        if dismissKeyboard {
            findBar.searchField.resignFirstResponder()
        }
        
        UIAccessibility.post(notification: .layoutChanged, argument: promptView)
    }
}

extension PhotoFindViewController {
    func changePromptToStarting(startingFilter: PhotoFilter, howManyPhotos: Int, isAllPhotos: Bool) {
        continueButtonVisible = false
         
        let findingFrom = NSLocalizedString("findingFrom", comment: "")
        
        let unit = NSLocalizedString("unitZhang", comment: "")
        
        let all = NSLocalizedString("allSpace", comment: "")
        let space = NSLocalizedString("blankSpace", comment: "")
        
        let photos = NSLocalizedString("findingFrom-photos", comment: "")
        
        let boldStyle = Style {
            $0.font = UIFont.systemFont(ofSize: 19, weight: .medium)
        }
        let grayStyle = Style {
            $0.color = UIColor.secondaryLabel
        }
        
        
        var number = isAllPhotos ? all : "\(howManyPhotos)\(unit)\(space)" /// number of all
        
        var overriddenLastPart: String?
        
        let filter: String
        let color: UIColor
        switch startingFilter {
        
        case .local:
            filter = "\(NSLocalizedString("lowercaseLocal", comment: ""))\(space)"
            color = UIColor(named: "100Blue")!
        case .starred:
            filter = "\(NSLocalizedString("lowercaseStarred", comment: ""))\(space)"
            color = UIColor(named: "Gold")!
        case .cached:
            filter = "\(NSLocalizedString("lowercaseCached", comment: ""))\(space)"
            color = UIColor(named: "100Blue")!
        case .all:
            filter = all
            color = UIColor(named: "TabIconPhotosMain")!
            if isAllPhotos {
                number = ""
            } else {
                let withinAllPhotos = NSLocalizedString("withinAllPhotos-Chinese", comment: "")
                if withinAllPhotos != "" { /// English is blank string
                    overriddenLastPart = "\(withinAllPhotos)\(howManyPhotos)\(unit)查找"
                } else {
                    number = "\(howManyPhotos) of "
                }
            }
        }
        
        let colorStyle = Style {
            $0.color = color
        }
        
        var attributedText = AttributedString()
        if let overriddenLastPart = overriddenLastPart {
            attributedText = findingFrom.set(styles: [boldStyle, grayStyle]) + filter.set(styles: [boldStyle, colorStyle]) + overriddenLastPart.set(styles: [boldStyle, grayStyle])
            
            promptView.accessibilityValue = findingFrom + filter + overriddenLastPart
            
            let summaryTitle = AccessibilityText(text: "Summary status:\n", isRaised: true)
            let summaryString = AccessibilityText(text: findingFrom + filter + overriddenLastPart, isRaised: false)
            postAnnouncement([summaryTitle, summaryString])
        } else {
            attributedText = findingFrom.set(styles: [boldStyle, grayStyle]) + number.set(styles: [boldStyle, grayStyle]) + filter.set(styles: [boldStyle, colorStyle]) + photos.set(styles: [boldStyle, grayStyle])
            
            promptView.accessibilityValue = findingFrom + number + filter + photos
            
            let summaryTitle = AccessibilityText(text: "Summary status:\n", isRaised: true)
            let summaryString = AccessibilityText(text: findingFrom + number + filter + photos, isRaised: false)
            postAnnouncement([summaryTitle, summaryString])
        }
        
        promptTextView.attributedText = attributedText
    }
    
    
    func setPromptToHowManyCacheResults(howMany: Int) {
        continueButtonVisible = true
        
        let textStyle = Style {
            $0.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            $0.color = UIColor.secondaryLabel
        }
        
        let resultsText = NSLocalizedString("resultsText", comment: "")
        let resultText = NSLocalizedString("resultText", comment: "")
        let inCachedPhotos = NSLocalizedString("inCachedPhotos", comment: "")
        
        let toFindFromUncachedPhotos = NSLocalizedString("toFindFromUncachedPhotos", comment: "")
        let toFindWithOCR = NSLocalizedString("toFindWithOCR", comment: "")
        
        var results = resultsText
        if howMany == 1 {
            results = resultText
        }
        
        let resultsInCache = " \(results)\(inCachedPhotos) "
        var toFindFromPhotos = " \(toFindFromUncachedPhotos)"
        
        if currentFilter == .cached {
            toFindFromPhotos = toFindWithOCR
        }
        
        let nextButtonAttachment = AttributedString(image: Image(named: "ContinueButton"), bounds: "0,-6,76,24")
        
        let attributedText = "\(howMany)".set(style: textStyle) + resultsInCache.set(style: textStyle) + nextButtonAttachment! + toFindFromPhotos.set(style: textStyle)
        promptTextView.attributedText = attributedText
        promptView.accessibilityValue = "\(howMany)" + resultsInCache + "Continue/Return button on the keyboard or double-tap this label" + toFindFromPhotos
        
        let summaryTitle = AccessibilityText(text: "Summary status:\n", isRaised: true)
        let summaryString = AccessibilityText(text: "\(howMany)" + resultsInCache + "Continue/Return button on the keyboard or double-tap Summary label" + toFindFromPhotos, isRaised: false)
        postAnnouncement([summaryTitle, summaryString])
    }
    func setPromptToHowManyFastFound(howMany: Int) { /// how many finished finding
        continueButtonVisible = false
        
        let textStyle = Style {
            $0.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            $0.color = UIColor.secondaryLabel
        }
        
        let findingFromUncachedPhotos = NSLocalizedString("findingFromUncachedPhotos", comment: "")
        let findingFromPhotos = NSLocalizedString("findingFromPhotos", comment: "")
        
        var attributedText = "\(findingFromUncachedPhotos) (\(howMany)/\(findPhotos.count))...".set(style: textStyle)
        
        if currentFilter == .cached {
            attributedText = "\(findingFromPhotos) (\(howMany)/\(findPhotos.count))...".set(style: textStyle)
            promptView.accessibilityValue = "\(findingFromPhotos) (\(howMany) out of \(findPhotos.count))..."
            
            let summaryTitle = AccessibilityText(text: "Summary status:\n", isRaised: true)
            let summaryString = AccessibilityText(text: "\(findingFromPhotos) (\(howMany) out of \(findPhotos.count))...", isRaised: false)
            postAnnouncement([summaryTitle, summaryString])
        } else {
            promptView.accessibilityValue = "\(findingFromUncachedPhotos) (\(howMany) out of \(findPhotos.count))..."
            
            let summaryTitle = AccessibilityText(text: "Summary status:\n", isRaised: true)
            let summaryString = AccessibilityText(text: "\(findingFromUncachedPhotos) (\(howMany) out of \(findPhotos.count))...", isRaised: false)
            postAnnouncement([summaryTitle, summaryString])
        }
        
        promptTextView.attributedText = attributedText
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
        
        let _in_ = NSLocalizedString("_in_", comment: "")
        let spaceOrZhangUnit = NSLocalizedString("spaceOrZhangUnit", comment: "")
        let lowercasePhotos = NSLocalizedString("lowercasePhotos", comment: "")
        
        let attributedText = "\(howMany)\(spaceOrUnit)\(results)\(_in_)\(resultPhotos.count)\(spaceOrZhangUnit)\(lowercasePhotos)".set(style: textStyle)
        promptTextView.attributedText = attributedText
        promptView.accessibilityValue = "Completed finding. \(howMany)\(spaceOrUnit)\(results)\(_in_)\(resultPhotos.count)\(spaceOrZhangUnit)\(lowercasePhotos)"
        
        let summaryTitle = AccessibilityText(text: "Summary status:\n", isRaised: true)
        let summaryString = AccessibilityText(text: "Completed finding. \(howMany)\(spaceOrUnit)\(results)\(_in_)\(resultPhotos.count)\(spaceOrZhangUnit)\(lowercasePhotos)", isRaised: false)

        postAnnouncement([summaryTitle, summaryString])
    }
    
    func postAnnouncement(_ accessibilityText: [AccessibilityText]) {
        if selfPresented?() ?? false {
            UIAccessibility.postAnnouncement(accessibilityText)
        } else {
            print("Currently not active")
        }
    }
}

