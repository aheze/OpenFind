//
//  VoiceOverSlidesControl.swift
//  Find
//
//  Created by Zheng on 3/27/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

class VoiceOverSlidesControl: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var numberLabel: UILabel!
    
    var currentIndex = 0
    var totalNumberOfPhotos = 1 {
        didSet {
            numberLabel.text = "\(currentIndex + 1)/\(totalNumberOfPhotos)"
        }
    }
    
    var goToNextPage: ((Bool) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override var accessibilityTraits: UIAccessibilityTraits {
        get {
            return .adjustable
        }
        set {
            super.accessibilityTraits = newValue
        }
    }
    override var accessibilityValue: String? {
        get {
            return "\(currentIndex + 1) out of \(totalNumberOfPhotos)"
        }
        
        set {
            super.accessibilityValue = newValue
        }
    }
    
    override func accessibilityIncrement() {
        if currentIndex < totalNumberOfPhotos - 1 {
            currentIndex += 1
            goToNextPage?(true)
            numberLabel.text = "\(currentIndex + 1)/\(totalNumberOfPhotos)"
        }
    }
    
    override func accessibilityDecrement() {
        if currentIndex > 0 {
            currentIndex -= 1
            goToNextPage?(false)
            numberLabel.text = "\(currentIndex + 1)/\(totalNumberOfPhotos)"
        }
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("VoiceOverSlidesControl", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.isAccessibilityElement = true
        self.accessibilityLabel = "Photo index"
        self.shouldGroupAccessibilityChildren = true
        
    }
}
