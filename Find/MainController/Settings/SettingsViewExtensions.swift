//
//  SettingsViewExtensions.swift
//  Find
//
//  Created by Andrew on 11/3/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

extension SettingsViewController {
    
    func setUpSettingsRoundedCorners() {
        
        
        highlightColorView.layer.cornerRadius = 10
        redButton.layer.cornerRadius = 4
        orangeButton.layer.cornerRadius = 4
        yellowButton.layer.cornerRadius = 4
        greenButton.layer.cornerRadius = 4
        tealButton.layer.cornerRadius = 4
        lightblueButton.layer.cornerRadius = 4
        findblueButton.layer.cornerRadius = 4
        purpleButton.layer.cornerRadius = 4
        
        
        otherSettingsView.layer.cornerRadius = 8
        otherSettingsView.clipsToBounds = true
        
        middleHelpView.layer.cornerRadius = 8
        middleHelpView.clipsToBounds = true
        
        moreSettingsView.layer.cornerRadius = 8
        moreSettingsView.clipsToBounds = true
        
        leaveFeedbackView.layer.cornerRadius = 8
        leaveFeedbackView.clipsToBounds = true
        
        rateAppView.layer.cornerRadius = 8
        rateAppView.clipsToBounds = true
        
        creditsView.layer.cornerRadius = 8
        creditsView.clipsToBounds = true
        
    }
    func setUpBasic() {
        redButton.tintColor = .white
        orangeButton.tintColor = .white
        yellowButton.tintColor = .white
        greenButton.tintColor = .white
        tealButton.tintColor = .white
        lightblueButton.tintColor = .white
        findblueButton.tintColor = .white
        purpleButton.tintColor = .white
        
        let image = UIImage(systemName: "checkmark")
        
        let defaults = UserDefaults.standard
        if let hexString = defaults.string(forKey: "highlightColor") {
            switch hexString {
            case "EB3B5A":
                redButton.setImage(image, for: .normal)
            case "FA8231":
                orangeButton.setImage(image, for: .normal)
            case "FED330":
                yellowButton.setImage(image, for: .normal)
            case "20BF6B":
                greenButton.setImage(image, for: .normal)
            case "2BCBBA":
                tealButton.setImage(image, for: .normal)
            case "45AAF2":
                lightblueButton.setImage(image, for: .normal)
            case "00AEEF":
                findblueButton.setImage(image, for: .normal)
            case "A55EEA":
                purpleButton.setImage(image, for: .normal)
            default:
                print("WRONG UserDe!!")
            }
        }
        
        let shouldShowTextDetectIndicator = defaults.bool(forKey: "showTextDetectIndicator")
        let shouldHapticFeedback = defaults.bool(forKey: "hapticFeedback")
        
        if shouldShowTextDetectIndicator {
            textDetectSwitch.setOn(true, animated: false)
        } else {
            textDetectSwitch.setOn(false, animated: false)
        }
        
        if shouldHapticFeedback {
            hapticFeedbackSwitch.setOn(true, animated: false)
        } else {
            hapticFeedbackSwitch.setOn(false, animated: false)
        }
    }
}
