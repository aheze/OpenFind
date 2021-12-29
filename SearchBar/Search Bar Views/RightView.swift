//
//  RightView.swift
//  SearchBar
//
//  Created by Zheng on 10/16/21.
//

import UIKit

class RightView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var buttonView: ButtonView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var imageViewWidthC: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeightC: NSLayoutConstraint!
    @IBOutlet weak var imageViewCenterXC: NSLayoutConstraint!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("RightView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let image = UIImage(systemName: "xmark")
        let configuration = UIImage.SymbolConfiguration(font: SearchConstants.fieldFont)
        imageView.preferredSymbolConfiguration = configuration
        imageView.image = image
        
        imageViewWidthC.constant = SearchConstants.fieldIconLength
        imageViewHeightC.constant = SearchConstants.fieldIconLength
        imageViewCenterXC.constant = -SearchConstants.fieldRightViewPadding
    }
}
