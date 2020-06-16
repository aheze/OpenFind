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
        
//        monthColorsView.layer.cornerRadius = 10
//        janButton.layer.cornerRadius = 10
//        febButton.layer.cornerRadius = 10
//        marButton.layer.cornerRadius = 10
//        aprButton.layer.cornerRadius = 10
//        mayButton.layer.cornerRadius = 10
//        junButton.layer.cornerRadius = 10
//        julButton.layer.cornerRadius = 10
//        augButton.layer.cornerRadius = 10
//        sepButton.layer.cornerRadius = 10
//        octButton.layer.cornerRadius = 10
//        novButton.layer.cornerRadius = 10
//        decButton.layer.cornerRadius = 10
        
//        prefilterView.layer.cornerRadius = 10
        
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
        
//        feedbackView.layer.cornerRadius = 10
//        feedbackView.layer.masksToBounds = true
        
        
        
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
//                defaults.set("EB3B5A", forKey: "highlightColor")
                print("red")
            case "FA8231":
                orangeButton.setImage(image, for: .normal)
//                defaults.set("FA8231", forKey: "highlightColor")
                print("org")
            case "FED330":
                yellowButton.setImage(image, for: .normal)
//                defaults.set("FED330", forKey: "highlightColor")
                print("yel")
            case "20BF6B":
                greenButton.setImage(image, for: .normal)
//                defaults.set("20BF6B", forKey: "highlightColor")
                print("gre")
            case "2BCBBA":
                tealButton.setImage(image, for: .normal)
//                defaults.set("2BCBBA", forKey: "highlightColor")
                print("teal")
            case "45AAF2":
                lightblueButton.setImage(image, for: .normal)
//                defaults.set("45AAF2", forKey: "highlightColor")
                print("blue")
            case "00AEEF":
                findblueButton.setImage(image, for: .normal)
//                defaults.set("00AEEF", forKey: "highlightColor")
                print("aeef")
            case "A55EEA":
                purpleButton.setImage(image, for: .normal)
//                defaults.set("A55EEA", forKey: "highlightColor")
                print("purple")
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
//    func addGestureRecognizers() {
//
//        let feedbackTap = UITapGestureRecognizer(target: self, action: #selector(self.feedbackTapped(_:)))
//        leaveFeedbackView.addGestureRecognizer(feedbackTap)
//
//        let rateTap = UITapGestureRecognizer(target: self, action: #selector(self.rateTapped(_:)))
//        rateAppView.addGestureRecognizer(rateTap)
//
//    }
//    @objc func feedbackTapped(_ sender: UITapGestureRecognizer? = nil) {
//        // handling code
//        print("TAPPP")
//    }
//    @objc func rateTapped(_ sender: UITapGestureRecognizer? = nil) {
//        print("RATEEE")
//        // handling code
//    }
    
}
