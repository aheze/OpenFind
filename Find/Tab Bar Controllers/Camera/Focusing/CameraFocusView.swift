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
    
    @IBOutlet weak var topLeft: UIImageView!
    @IBOutlet weak var topRight: UIImageView!
    @IBOutlet weak var bottomRight: UIImageView!
    @IBOutlet weak var bottomLeft: UIImageView!
    
    
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
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        topRight.transform = CGAffineTransform(rotationAngle: 90.degreesToRadians)
        bottomRight.transform = CGAffineTransform(rotationAngle: 180.degreesToRadians)
        bottomLeft.transform = CGAffineTransform(rotationAngle: 270.degreesToRadians)
        
    }
}
