//
//  LeftView.swift
//  SearchBar
//
//  Created by Zheng on 10/16/21.
//

import UIKit

class LeftView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet var buttonView: ButtonView!

    @IBOutlet var findIconView: FindIconUIView!
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
        Bundle.main.loadNibNamed("LeftView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        iconViewCenterXC.constant = configuration.fieldLeftViewPadding
    }
}
