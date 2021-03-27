//
//  SegmentedSlider+Accessibility.swift
//  Find
//
//  Created by Zheng on 3/25/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension SegmentedSlider {
    func setupAccessibility() {
        self.isAccessibilityElement = true
        self.accessibilityLabel = "Filters"
        self.shouldGroupAccessibilityChildren = true
    }
}
