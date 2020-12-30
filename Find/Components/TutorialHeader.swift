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
    @IBOutlet weak var colorView: UIView!
    
    @IBOutlet weak var startTourButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var colorViewHeightConst: NSLayoutConstraint!
    
    
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
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
