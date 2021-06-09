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
        starButton.accessibilityLabel = "Starred filter"
        starButton.accessibilityHint = "Show only starred photos"
        starButton.accessibilityValue = "Inactive"
        cacheButton.accessibilityLabel = "Cached filter"
        cacheButton.accessibilityHint = "Show only cached photos"
        cacheButton.accessibilityValue = "Inactive"
        
        containerView.isAccessibilityElement = true
        containerView.accessibilityLabel = "Categories"
        containerView.shouldGroupAccessibilityChildren = true
        
        containerView.getAccessibilityTraits = { [weak self] in
            guard let self = self else { return .none }
            return self.showingPhotosSelection ? .none : .adjustable
        }
        containerView.getAccessibilityValue = { [weak self] in
            guard let self = self else { return "None" }
            if self.showingPhotosSelection == false {
                switch self.photoFilterState.currentFilter {
                case .local:
                    return "Local"
                case .screenshots:
                    return "Screenshots"
                case .all:
                    return "All"
                }
            } else {
                return nil
            }
        }
        containerView.accessibilityIncremented = { [weak self] in
            guard let self = self else { return }
            switch self.photoFilterState.currentFilter {
            case .local:
                self.photoFilterState.currentFilter = .screenshots
            case .screenshots:
                self.photoFilterState.currentFilter = .all
            case .all:
                break
            }
            self.animateChangeSelection(filter: self.photoFilterState.currentFilter)
            self.pressedFilter?(self.photoFilterState)
        }
        containerView.accessibilityDecremented = { [weak self] in
            guard let self = self else { return }
            switch self.photoFilterState.currentFilter {
            case .local:
                break
            case .screenshots:
                self.photoFilterState.currentFilter = .local
            case .all:
                self.photoFilterState.currentFilter = .screenshots
            }
            self.animateChangeSelection(filter: self.photoFilterState.currentFilter)
            self.pressedFilter?(self.photoFilterState)
        }
    }
}

class SliderCategoriesView: UIView {
    var getAccessibilityTraits: (() -> UIAccessibilityTraits)?
    var getAccessibilityValue: (() -> String?)?
    var accessibilityIncremented: (() -> Void)?
    var accessibilityDecremented: (() -> Void)?
    
    override var accessibilityTraits: UIAccessibilityTraits {
        get {
            return getAccessibilityTraits?() ?? .none
        }
        set {
            super.accessibilityTraits = newValue
        }
    }
    override var accessibilityValue: String? {
        get {
            return getAccessibilityValue?()
        }
        set {
            super.accessibilityValue = newValue
        }
    }
    
    override func accessibilityIncrement() {
        accessibilityIncremented?()
    }
    
    override func accessibilityDecrement() {
        accessibilityDecremented?()
    }
}
