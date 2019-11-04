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
        janButton.layer.cornerRadius = 6
        febButton.layer.cornerRadius = 6
        marButton.layer.cornerRadius = 6
        aprButton.layer.cornerRadius = 6
        mayButton.layer.cornerRadius = 6
        junButton.layer.cornerRadius = 6
        julButton.layer.cornerRadius = 6
        augButton.layer.cornerRadius = 6
        sepButton.layer.cornerRadius = 6
        octButton.layer.cornerRadius = 6
        novButton.layer.cornerRadius = 6
        decButton.layer.cornerRadius = 6
        
        prefilterView.layer.cornerRadius = 10
        otherSettingsView.clipsToBounds = true
        otherSettingsView.layer.cornerRadius = 10
        creditsView.layer.cornerRadius = 10
        
        
        
    }
    
}
