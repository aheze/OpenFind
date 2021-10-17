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
        let bundle = Bundle(identifier: "com.aheze.SearchBar")
        bundle?.loadNibNamed("LeftView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        imageView.image = UIImage(systemName: "plus")
        buttonView.tapped = { [weak self] in
            print("tapped!")
            self?.tapped?()
        }
    }
}

