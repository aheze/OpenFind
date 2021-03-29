//
//  PostAnnouncement.swift
//  Find
//
//  Created by Zheng on 3/28/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

struct AccessibilityText {
    var text = ""
    var isRaised = false
    var customPitch: Double? = nil
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
