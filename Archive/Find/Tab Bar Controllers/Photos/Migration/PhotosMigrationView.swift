//
//  PhotosMigrationView.swift
//  Find
//
//  Created by Zheng on 12/31/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

class PhotosMigrationView: UIView {
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var explanation1Label: UILabel!
    @IBOutlet var explanation2Label: UILabel!
    
    var movePressed: (() -> Void)?
    @IBOutlet var moveButton: UIButton!
    @IBAction func moveButtonPressed(_ sender: Any) {
        movePressed?()
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
        Bundle.main.loadNibNamed("PhotosMigrationView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        moveButton.layer.cornerRadius = 12
    }
}
