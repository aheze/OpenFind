//
//  SettingsViewExtensions.swift
//  Find
//
//  Created by Andrew on 11/3/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import Foundation

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
        
        monthColorsView.layer.cornerRadius = 10
        janButton.layer.cornerRadius = 10
        febButton.layer.cornerRadius = 10
        marButton.layer.cornerRadius = 10
        aprButton.layer.cornerRadius = 10
        mayButton.layer.cornerRadius = 10
        junButton.layer.cornerRadius = 10
        julButton.layer.cornerRadius = 10
        augButton.layer.cornerRadius = 10
        sepButton.layer.cornerRadius = 10
        octButton.layer.cornerRadius = 10
        novButton.layer.cornerRadius = 10
        decButton.layer.cornerRadius = 10
        
        prefilterView.layer.cornerRadius = 10
        otherSettingsView.clipsToBounds = true
        otherSettingsView.layer.cornerRadius = 10
        creditsView.layer.cornerRadius = 10
        
        
        
    }
    
}
