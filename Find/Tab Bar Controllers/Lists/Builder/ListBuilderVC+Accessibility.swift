//
//  ListBuilderVC+Accessibility.swift
//  Find
//
//  Created by Zheng on 3/28/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension ListBuilderViewController {
    func setupAccessibility() {
        cancelButton.accessibilityHint = "Discard all changes and dismiss this screen"
        
        saveButton.accessibilityHint = "Save all changes and dismiss this screen, if there are no errors in the Words to Find"
        
        topImageView.isAccessibilityElement = true
        topImageView.accessibilityTraits = .image
        topImageView.accessibilityLabel = "Icon/color preview"
        
        updateTopImageLabel()
    }
    func updateTopImageLabel() {
        let colorDescription = iconColorName.getDescription()
        
        let iconTitle = AccessibilityText(text: "Icon", isRaised: true)
        let iconString = AccessibilityText(text: iconImageName, isRaised: false)
        let colorTitle = AccessibilityText(text: "\nColor", isRaised: true)
        let colorString = AccessibilityText(text: "\(colorDescription.0)", isRaised: false)
        let pitchTitle = AccessibilityText(text: "\nPitch", isRaised: true)
        let pitchString = AccessibilityText(text: "\(colorDescription.1)", isRaised: false, customPitch: colorDescription.1)
        
        let accessibilityLabel = UIAccessibility.makeAttributedText(
            [
                iconTitle, iconString,
                colorTitle, colorString,
                pitchTitle, pitchString,
            ]
        )
        
        topImageView.accessibilityAttributedValue = accessibilityLabel
    }
}
