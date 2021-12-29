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
    
    func setTint(color: UIColor) {
        topHighlightView.backgroundColor = color
        middleHighlightView.backgroundColor = color.toColor(.white, percentage: 0.3)
        bottomHighlightView.backgroundColor = color.toColor(.white, percentage: 0.6)
    }
    
    struct Configuration {
        var frame: CGRect
        var autoresizingMask: UIView.AutoresizingMask
        var cornerRadius: CGFloat
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
