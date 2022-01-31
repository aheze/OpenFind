//
//  FindIconUIView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/22/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

class FindIconUIView: UIView {
    static let spacingPercent = CGFloat(0.09)
    
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
        isUserInteractionEnabled = false
        backgroundColor = .clear
        let spacing = FindIconUIView.spacingPercent * bounds.height
        
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
