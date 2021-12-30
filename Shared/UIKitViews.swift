//
//  UIKitViews.swift
//  Popover
//
//  Created by Zheng on 12/3/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

class FindIconView: UIView {
    let spacingPercent = CGFloat(0.09)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    var topHighlightView: UIView!
    var middleHighlightView: UIView!
    var bottomHighlightView: UIView!

    private func commonInit() {
        backgroundColor = .clear
        let spacing = spacingPercent * bounds.height
        
        /// total height of highlights
        let availableHeightForHighlights = bounds.height - (2 * spacing)
        let highlightHeight = availableHeightForHighlights / 3
        
        let topHighlightConfiguration = Configuration(
            frame: CGRect(x: 0, y: 0, width: bounds.width, height: highlightHeight),
            autoresizingMask: [.flexibleWidth, .flexibleHeight, .flexibleRightMargin, .flexibleBottomMargin],
            cornerRadius: highlightHeight / 2
        )
        let middleHighlightConfiguration = Configuration(
            frame: CGRect(x: 0, y: highlightHeight + spacing, width: (highlightHeight * 2) + spacing, height: highlightHeight),
            autoresizingMask: [.flexibleWidth, .flexibleHeight, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin],
            cornerRadius: highlightHeight / 2
        )
        let bottomHighlightConfiguration = Configuration(
            frame: CGRect(x: 0, y: 2 * (highlightHeight + spacing), width: highlightHeight, height: highlightHeight),
            autoresizingMask: [.flexibleWidth, .flexibleHeight, .flexibleRightMargin, .flexibleTopMargin],
            cornerRadius: highlightHeight / 2
        )
        
        let configurations = [topHighlightConfiguration, middleHighlightConfiguration, bottomHighlightConfiguration]
        for (index, configuration) in configurations.enumerated() {
            let highlightView = UIView(frame: configuration.frame)
            highlightView.autoresizingMask = configuration.autoresizingMask
            highlightView.layer.cornerRadius = configuration.cornerRadius
            addSubview(highlightView)
            
            switch index {
            case 0:
                topHighlightView = highlightView
            case 1:
                middleHighlightView = highlightView
            case 2:
                bottomHighlightView = highlightView
            default:
                assertionFailure("Out of bounds")
            }
        }
    }
    
    func setTint(color: UIColor, alpha: CGFloat) {
        let alphaAdjustedColor = color.toColor(.white, percentage: 1 - alpha)
        topHighlightView.backgroundColor = alphaAdjustedColor
        middleHighlightView.backgroundColor = alphaAdjustedColor.toColor(.white, percentage: 0.3)
        bottomHighlightView.backgroundColor = alphaAdjustedColor.toColor(.white, percentage: 0.6)
    }
    
    struct Configuration {
        var frame: CGRect
        var autoresizingMask: UIView.AutoresizingMask
        var cornerRadius: CGFloat
    }
}

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

class ButtonView: UIButton {
    var tapped: (() -> Void)?
    var shouldFade = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    func configure() {
        addTarget(self, action: #selector(touchDown(_:)), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(touchFinish(_:)), for: [.touchUpInside, .touchCancel, .touchDragExit])
        addTarget(self, action: #selector(touchConfirm(_:)), for: [.touchUpInside, .touchDragEnter])
    }

    @objc func touchDown(_ sender: UIButton) {
        fade(true)
    }

    @objc func touchFinish(_ sender: UIButton) {
        fade(false)
    }

    @objc func touchConfirm(_ sender: UIButton) {
        tapped?()
    }
    
    func fade(_ fade: Bool) {
        if shouldFade {
            if fade {
                UIView.animate(withDuration: 0.2, animations: {
                    self.alpha = 0.5
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.alpha = 1
                })
            }
        }
    }
}
