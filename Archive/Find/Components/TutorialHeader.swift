//
//  TutorialHeader.swift
//  Find
//
//  Created by Zheng on 12/28/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

class TutorialHeader: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet var colorView: UIView!
    
    @IBOutlet var startTourButton: UIButton!
    @IBOutlet var closeButton: UIButton!
    
    @IBOutlet var colorViewHeightConst: NSLayoutConstraint!
    
    var pressed: (() -> Void)?
    var closed: (() -> Void)?
    
    @IBAction func startButtonPressed(_ sender: Any) {
        pressed?()
    }

    @IBAction func closeButtonPressed(_ sender: Any) {
        closed?()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("TutorialHeader", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        startTourButton.accessibilityHint = "Present a quick tutorial"
        closeButton.accessibilityHint = "Dismiss the tutorial banner"
    }
}
