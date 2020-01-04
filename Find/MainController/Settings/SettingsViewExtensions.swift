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
        otherSettingsView.layer.masksToBounds = true
        otherSettingsView.layer.cornerRadius = 10
        creditsView.layer.masksToBounds = true
        creditsView.layer.cornerRadius = 10
        feedbackView.layer.cornerRadius = 10
        feedbackView.layer.masksToBounds = true
        
        
        
    }
    func addGestureRecognizers() {
        let watchTap = UILongPressGestureRecognizer(target: self, action: #selector(self.watchTapped(_:)))
        watchTap.minimumPressDuration = 0
        watchTutorialView.addGestureRecognizer(watchTap)
        
        let clearHistTap = UILongPressGestureRecognizer(target: self, action: #selector(self.clearHistTapped(_:)))
        clearHistTap.minimumPressDuration = 0
        clearHistoryView.addGestureRecognizer(clearHistTap)
        
        let resetTap = UILongPressGestureRecognizer(target: self, action: #selector(self.resetTapped(_:)))
        resetTap.minimumPressDuration = 0
        resetSettingsView.addGestureRecognizer(resetTap)
        
        let rateTap = UILongPressGestureRecognizer(target: self, action: #selector(self.rateTapped(_:)))
        rateTap.minimumPressDuration = 0
        rateAppView.addGestureRecognizer(rateTap)
        
        let helpTap = UILongPressGestureRecognizer(target: self, action: #selector(self.helpTapped(_:)))
        helpTap.minimumPressDuration = 0
        helpView.addGestureRecognizer(helpTap)
    }
    func setUpGradientFeedback() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(named: "FeedbackGradientLeft")?.cgColor, UIColor(named: "FeedbackGradientRight")?.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: feedbackView.frame.size.width, height: feedbackView.frame.size.height)
        feedbackView.layer.insertSublayer(gradientLayer, at: 0)
    }
}
