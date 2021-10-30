//
//  TabBarView.swift
//  TabBarController
//
//  Created by Zheng on 10/28/21.
//

import UIKit

class TabBarView: UIView {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var photosButtonView: ButtonView!
    
    @IBOutlet weak var cameraButtonView: ButtonView!
    
    @IBOutlet weak var listsButtonView: ButtonView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        let bundle = Bundle(identifier: "com.aheze.TabBarController")
        bundle?.loadNibNamed("TabBarView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
