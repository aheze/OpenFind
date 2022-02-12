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
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var iconViewCenterXC: NSLayoutConstraint!
    @IBOutlet var imageViewCenterXC: NSLayoutConstraint!
    
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
        
        imageView.contentMode = .center
        imageView.preferredSymbolConfiguration = .init(font: configuration.fieldListIconFont)
    }
    
    func setConfiguration() {
        iconViewCenterXC.constant = configuration.fieldLeftIconViewPadding
        imageViewCenterXC.constant = configuration.fieldLeftImageViewPadding
    }
}
