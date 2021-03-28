//
//  PhotoFindVC+Accessibility.swift
//  Find
//
//  Created by Zheng on 3/27/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotoFindViewController {
    func setupAccessibility() {
        promptTextView.accessibilityLabel = "Prompt"
        promptTextView.accessibilityTraits = .updatesFrequently
        promptTextView.accessibilityValue = promptTextView.text
    }
}
