//
//  RightView.swift
//  SearchBar
//
//  Created by Zheng on 10/16/21.
//

import UIKit

class RightView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet var buttonView: ButtonView!
    
    
    @IBOutlet weak var clearIconView: ClearIconView!
    @IBOutlet var iconViewWidthC: NSLayoutConstraint!
    @IBOutlet var iconViewHeightC: NSLayoutConstraint!
    @IBOutlet var iconViewCenterXC: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    var configuration = SearchConfiguration()
    
    private func commonInit() {
        Bundle.main.loadNibNamed("RightView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func setConfiguration() {
        iconViewWidthC.constant = configuration.clearIconLength
        iconViewHeightC.constant = configuration.clearIconLength
        iconViewCenterXC.constant = -configuration.fieldRightViewPadding
        clearIconView.backgroundView.backgroundColor = configuration.clearBackgroundColor
        clearIconView.iconView.tintColor = configuration.clearImageColor
    }
}
