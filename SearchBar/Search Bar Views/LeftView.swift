//
//  LeftView.swift
//  SearchBar
//
//  Created by Zheng on 10/16/21.
//

import UIKit

class LeftView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var buttonView: ButtonView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var imageViewWidthC: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeightC: NSLayoutConstraint!
    
    var tapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("LeftView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        buttonView.tapped = tapped
        
        imageViewWidthC.constant = SearchConstants.fieldIconLength
        imageViewHeightC.constant = SearchConstants.fieldIconLength
    }
}

