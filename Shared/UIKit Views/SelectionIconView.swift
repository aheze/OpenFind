//
//  SelectionIconView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/22/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

class SelectionIconView: UIView {
    
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
        view.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.05)
        view.layer.cornerRadius = bounds.height / 2
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 3
        
        addSubview(view)
        return view
    }()
    
    lazy var iconView: UIImageView = {
        let image = UIImage(systemName: "checkmark")
        let imageView = UIImageView(image: image)
        imageView.tintColor = .white
        imageView.contentMode = .center
        imageView.preferredSymbolConfiguration = .init(font: .preferredFont(forTextStyle: .headline))
        
        imageView.frame = bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(imageView)
        return imageView
    }()
    
    private func commonInit() {
        backgroundColor = .clear
        
        _ = backgroundView
        _ = iconView
        
        setState(.selected)
        
    }
    
    func setState(_ state: State, animated: Bool = false) {
        UIView.animate(withDuration: animated ? 0.3 : 0) {
            
            switch state {
            case .hidden:
                self.backgroundView.alpha = 0
                self.iconView.alpha = 0
            case .empty:
                self.backgroundView.alpha = 1
                self.backgroundView.backgroundColor = .clear
                self.iconView.alpha = 0
            case .selected:
                self.backgroundView.alpha = 0
                self.backgroundView.backgroundColor = .systemBlue
                self.iconView.alpha = 1
            }
        }
    }
    
    enum State {
        case hidden
        case empty
        case selected
    }
}
