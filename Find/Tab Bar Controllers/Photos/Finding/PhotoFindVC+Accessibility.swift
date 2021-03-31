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
        promptView.isAccessibilityElement = true
        promptView.shouldGroupAccessibilityChildren = true
        promptView.accessibilityLabel = "Summary"
        promptView.accessibilityTraits = [.header, .updatesFrequently]
        promptView.accessibilityValue = "Finding from photos"
        
        promptView.activated = { [weak self] in
            guard let self = self else { return false }
            
            if self.continueButtonVisible {
                self.continuePressed()
                return true
            }
            return false
        }
    }
}

class PromptView: UIView {
    
    var activated: (() -> Bool)?
    
    override func accessibilityActivate() -> Bool {
        print("Activate??")
        return activated?() ?? false
    }
    override var accessibilityCustomActions: [UIAccessibilityCustomAction]? {
        get {
            return nil
        }
        set {
            super.accessibilityCustomActions = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
    }
}

