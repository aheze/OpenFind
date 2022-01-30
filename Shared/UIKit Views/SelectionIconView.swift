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
            backgroundView.frame.size = configuration.attributes.size
            backgroundView.centerInParent()
            backgroundView.layer.cornerRadius = backgroundView.bounds.height / 2
            iconView.preferredSymbolConfiguration = .init(font: configuration.attributes.iconFont)
        }
    }
    
    lazy var backgroundView: UIView = {
        let view = UIView()
        addSubview(view)
        
        view.frame.size = configuration.attributes.size
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
        imageView.preferredSymbolConfiguration = .init(font: configuration.attributes.iconFont)
        
        imageView.frame = bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(imageView)
        return imageView
    }()
    
    private func commonInit() {
        backgroundColor = .clear
        _ = backgroundView
        _ = iconView
        isUserInteractionEnabled = false
        
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
                self.backgroundView.layer.borderColor = self.configuration.attributes.rimColor.cgColor
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
        struct Attributes {
            var size = CGSize(width: 18, height: 18)
            var iconFont = UIFont.systemFont(ofSize: 11, weight: .medium)
            var rimColor = UIColor.secondaryLabel
        }
        
        case regular
        case large
        case listsSelection
        
        var attributes: Attributes {
            switch self {
            case .regular:
                return Attributes()
            case .large:
                var attributes = Attributes()
                attributes.size = CGSize(width: 22, height: 22)
                attributes.iconFont = .systemFont(ofSize: 14, weight: .medium)
                return attributes
            case .listsSelection:
                var attributes = Attributes()
                attributes.size = CGSize(width: 22, height: 22)
                attributes.iconFont = .systemFont(ofSize: 14, weight: .medium)
                attributes.rimColor = .white
                return attributes
            }
        }
    }
    
    enum State {
        case hidden
        case empty
        case selected
    }
}
