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

struct PromptStringAttributes {
    var range: NSRange
    var color: UIColor
}
extension PhotoFindViewController {
    func changePromptToStarting(startingFilterState: PhotoFilterState, howManyPhotos: Int, isAllPhotos: Bool, announce: Bool = true) {
        continueButtonVisible = false
        
        let findingFrom = "Finding from "
        var number = "\(howManyPhotos) "
        var filter = ""
        var folder: String
        
        var combinedPromptString = ""
        
        if photoFilterState.starSelected || photoFilterState.cacheSelected {
            if photoFilterState.starSelected && photoFilterState.cacheSelected {
                filter = "starred + cached "
            } else if photoFilterState.starSelected {
                filter = "starred "
            } else {
                filter = "cached "
            }
        }
        
        switch photoFilterState.currentFilter {
        case .local:
            folder = "local photos"
        case .screenshots:
            folder = "screenshots"
        case .all:
            folder = "photos"
            
            if isAllPhotos {
                number = "all \(number)"
            } else {
                number = "\(number)of all "
            }
        }
        
        if combinedPromptString.isEmpty {
            combinedPromptString = findingFrom + number + filter + folder
        }
        
        let attributes: [PromptStringAttributes] = PhotoTutorialType.allCases.compactMap {
            let typeName = $0.getName().1.lowercased()
            if let substringRange = combinedPromptString.range(of: typeName) {
                let nsRange = NSRange(substringRange, in: combinedPromptString)
                let promptString = PromptStringAttributes(range: nsRange, color: $0.getColor())
                return promptString
            }
            return nil
        }
        
        let boldStyle = Style { $0.font = UIFont.systemFont(ofSize: 19, weight: .medium) }
        let grayStyle = Style { $0.color = UIColor.secondaryLabel }
        let attributedText = combinedPromptString.set(styles: [boldStyle, grayStyle])
        
        for attribute in attributes {
            let style = Style {
                $0.color = attribute.color
            }
            attributedText.set(styles: [style], range: attribute.range)
        }
        
        if announce {
            let summaryTitle = AccessibilityText(text: "Summary status:\n", isRaised: true)
            let summaryString = AccessibilityText(text: combinedPromptString, isRaised: false)
            postAnnouncement([summaryTitle, summaryString])
        }
        
        promptTextView.attributedText = attributedText
        promptView.accessibilityValue = combinedPromptString
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
        
        if photoFilterState.cacheSelected {
            toFindFromPhotos = toFindWithOCR
        }
        
        let nextButtonAttachment = AttributedString(image: Image(named: "ContinueButton"), bounds: "0,-6,76,24")
        
        let attributedText = "\(howMany)".set(style: textStyle) + resultsInCache.set(style: textStyle) + nextButtonAttachment! + toFindFromPhotos.set(style: textStyle)
        promptTextView.attributedText = attributedText
        promptView.accessibilityValue = "\(howMany)" + resultsInCache + "Continue/Return button on the keyboard, or double-tap this label " + toFindFromPhotos
        
        let summaryTitle = AccessibilityText(text: "Summary status:\n", isRaised: true)
        let summaryString = AccessibilityText(text: "\(howMany)" + resultsInCache + "Continue/Return button on the keyboard, or double-tap Summary label " + toFindFromPhotos, isRaised: false)
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
        
        var attributedText = photoFilterState.cacheSelected
            ? "\(findingFromPhotos) (\(howMany)/\(findPhotos.count))...".set(style: textStyle)
            : "\(findingFromUncachedPhotos) (\(howMany)/\(findPhotos.count))...".set(style: textStyle)
        
        let plainText = photoFilterState.cacheSelected
            ? "\(findingFromPhotos) (\(howMany) out of \(findPhotos.count))..."
            : "\(findingFromUncachedPhotos) (\(howMany) out of \(findPhotos.count))..."
        
        
        if howMany % 15 == 0 {
            let summaryTitle = AccessibilityText(text: "Summary status:\n", isRaised: true)
            let summaryString = AccessibilityText(text: plainText, isRaised: false)
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


