//
//  Utilities+Accessibility.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/2/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import SwiftUI

extension View {
    /// accessibility label
    func accessibilityLabel(_ string: String) -> some View {
        accessibility(label: Text(string))
    }
    
    func accessibilityValue(_ string: String) -> some View {
        accessibility(value: Text(string))
    }
    
    func accessibilityHint(_ string: String) -> some View {
        accessibility(hint: Text(string))
    }
}

extension UIColor {
    var readableDescription: String {
        if #available(iOS 14.0, *) {
            return self.accessibilityName
        } else {
            return "#\(self.hexString)"
        }
    }
}

struct AccessibilityText {
    var text = ""
    var isRaised = false
    var customPitch: Double? = nil
    var customPronunciation: String? = nil
}

extension UIAccessibility {
    static func postAnnouncement(_ texts: [AccessibilityText], delay: Double = 0.5) {
        let string = makeAttributedText(texts)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            UIAccessibility.post(notification: .announcement, argument: string)
        }
    }
    
    static func makeAttributedText(_ texts: [AccessibilityText]) -> NSMutableAttributedString {
        let pitch = [NSAttributedString.Key.accessibilitySpeechPitch: 1.2]
        let string = NSMutableAttributedString()
        
        for text in texts {
            if let customPitch = text.customPitch {
                let pitch = [NSAttributedString.Key.accessibilitySpeechPitch: customPitch]
                let customRaisedString = NSMutableAttributedString(string: text.text, attributes: pitch)
                string.append(customRaisedString)
            } else if let customPronunciation = text.customPronunciation {
                let pronunciation = [NSAttributedString.Key.accessibilitySpeechIPANotation: NSString(string: customPronunciation)]
                let customPronunciationString = NSMutableAttributedString(string: text.text, attributes: pronunciation)
                string.append(customPronunciationString)
            } else if text.isRaised {
                let raisedString = NSMutableAttributedString(string: text.text, attributes: pitch)
                string.append(raisedString)
            } else {
                let normalString = NSAttributedString(string: text.text)
                string.append(normalString)
            }
        }
        
        return string
    }
}
