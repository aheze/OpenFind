//
//  SelectionIconView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/22/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

class SelectionIconView: UIView {
    
    init(configuration: Configuration = .regular) {
        super.init(frame: .zero)
        commonInit()
    }
    
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
        backgroundView.layer.cornerRadius = backgroundView.bounds.height / 2
    }
    
    var configuration = Configuration.regular {
        didSet {
            backgroundView.frame.size = configuration.size
            backgroundView.centerInParent()
            backgroundView.layer.cornerRadius = backgroundView.bounds.height / 2
            iconView.preferredSymbolConfiguration = .init(font: configuration.iconFont)
        }
    }
    
    lazy var backgroundView: UIView = {
        let view = UIView()
        addSubview(view)
        
        view.frame.size = configuration.size
        view.centerInParent()
        
        view.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.05)
        view.layer.cornerRadius = view.bounds.height / 2
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 1.5
    
        return view
    }()
    
    lazy var iconView: UIImageView = {
        let image = UIImage(systemName: "checkmark")
        let imageView = UIImageView(image: image)
        imageView.tintColor = .white
        imageView.contentMode = .center
        imageView.preferredSymbolConfiguration = .init(font: configuration.iconFont)
        
        imageView.frame = bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(imageView)
        return imageView
    }()
    
    private func commonInit() {
        backgroundColor = .clear
        _ = backgroundView
        _ = iconView
        self.isUserInteractionEnabled = false
        
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
                self.backgroundView.layer.borderColor = UIColor.secondaryLabel.cgColor
                self.iconView.alpha = 0
            case .selected:
                self.backgroundView.alpha = 1
                self.backgroundView.backgroundColor = .systemBlue
                self.backgroundView.layer.borderColor = UIColor.systemBlue.cgColor
                self.iconView.alpha = 1
            }
        }
    }
    
    enum Configuration {
        case regular
        case large
        
        var size: CGSize {
            switch self {
            case .regular:
                return CGSize(width: 18, height: 18)
            case .large:
                return CGSize(width: 22, height: 22)
            }
        }
        
        var iconFont: UIFont {
            switch self {
            case .regular:
                return .systemFont(ofSize: 11, weight: .medium)
            case .large:
                return .systemFont(ofSize: 14, weight: .medium)
            }
        }
    }
    
    enum State {
        case hidden
        case empty
        case selected
    }
}
