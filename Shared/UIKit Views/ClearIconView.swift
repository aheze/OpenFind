//
//  ClearIconView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/22/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

class ClearIconView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView.layer.cornerRadius = bounds.height / 2
    }
    
    lazy var backgroundView: UIView = {
        let view = UIView()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        view.layer.cornerRadius = bounds.height / 2
        addSubview(view)
        return view
    }()
    lazy var iconView: UIImageView = {

        let image = UIImage(named: "xmark")
        let imageView = UIImageView(image: image)
        imageView.frame = bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.tintColor = UIColor.white.withAlphaComponent(0.75)
        addSubview(imageView)
        return imageView
    }()
    
    private func commonInit() {
        backgroundColor = .clear
        isUserInteractionEnabled = false
        _ = backgroundView
        _ = iconView
        
        setState(.hidden)
        
    }
    
    func setState(_ state: State, animated: Bool = false) {
        UIView.animate(withDuration: animated ? 0.3 : 0) {
            
            switch state {
            case .hidden:
                self.backgroundView.alpha = 0
                self.iconView.alpha = 0
            case .clear:
                self.backgroundView.alpha = 1
                self.backgroundView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                self.iconView.alpha = 1
                self.iconView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            case .delete:
                self.backgroundView.alpha = 0
                self.backgroundView.transform = .identity
                self.iconView.alpha = 1
                self.iconView.transform = .identity
            }
        }
    }
    
    enum State {
        case hidden
        case clear
        case delete
    }
}
