//
//  CameraFocusView.swift
//  Find
//
//  Created by Zheng on 3/5/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

class CameraFocusView: UIView {
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var topLeft: UIImageView!
    @IBOutlet var topRight: UIImageView!
    @IBOutlet var bottomRight: UIImageView!
    @IBOutlet var bottomLeft: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("CameraFocusView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
