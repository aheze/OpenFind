//
//  FindBar+Accessibility.swift
//  Find
//
//  Created by Zheng on 3/29/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension FindBar {
    func setupAccessibility() {
        searchField.accessibilityTraits = UIAccessibilityTraits(rawValue: 0x200000000000)
        searchField.accessibilityLabel = "Search bar"
    }
}
