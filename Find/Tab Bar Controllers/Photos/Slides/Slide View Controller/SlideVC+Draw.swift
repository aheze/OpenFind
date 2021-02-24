//
//  SlideVC+Draw.swift
//  Find
//
//  Created by Zheng on 1/18/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import AVFoundation

extension SlideViewController {
    func removeAllHighlights() {
        drawingView.subviews.forEach({ $0.removeFromSuperview() })
    }
    func drawHighlights() {
        removeAllHighlights()
        
        let aspectFrame = AVMakeRect(aspectRatio: imageView.image?.size ?? imageView.bounds.size, insideRect: contentView.bounds)
        
        for comp in highlights {
            
            let newX = comp.x * (aspectFrame.width) + aspectFrame.origin.x
            let newWidth = comp.width * aspectFrame.width
            let newY = comp.y * (aspectFrame.height) + aspectFrame.origin.y
            let newHeight = comp.height * aspectFrame.height
            
            let compToScale = Component()
            compToScale.x = newX - 6
            compToScale.y = newY - 3
            compToScale.width = newWidth + 12
            compToScale.height = newHeight + 6
            compToScale.colors = comp.colors
            compToScale.text = comp.text
            
            if newHeight <= 50 {
                scaleInHighlight(originalComponent: comp, component: compToScale)
            } else {
                scaleInHighlight(originalComponent: comp, component: compToScale, unsure: true)
            }
        }
    }
    
    func updateHighlightFrames() {
        let aspectFrame = AVMakeRect(aspectRatio: imageView.image?.size ?? imageView.bounds.size, insideRect: contentView.bounds)
        for (highlight, uiView) in drawnHighlights {
            let newX = highlight.x * (aspectFrame.width) + aspectFrame.origin.x - 6
            let newWidth = highlight.width * aspectFrame.width + 12
            let newY = highlight.y * (aspectFrame.height) + aspectFrame.origin.y - 3
            let newHeight = highlight.height * aspectFrame.height + 6
            
            uiView.frame = CGRect(x: newX, y: newY, width: newWidth, height: newHeight)
        }
    }
    
    func scaleInHighlight(originalComponent: Component, component: Component, unsure: Bool = false) {
        guard let colors = matchToColors[component.text] else { return }
        
        let layer = CALayer()
        layer.frame = CGRect(x: 0, y: 0, width: component.width, height: component.height)
        layer.cornerRadius = component.height / 3.5
        
        let rimLayer = CALayer()
        rimLayer.bounds = layer.frame
        rimLayer.cornerRadius = component.height / 3.5
        rimLayer.borderWidth = 3
        
        if colors.count > 1 {            
            let gradient = CAGradientLayer()
            gradient.frame = layer.bounds
            if let gradientColors = self.matchToColors[component.text] {
                gradient.colors = gradientColors
                if let firstColor = gradientColors.first {
                    layer.backgroundColor = UIColor(cgColor: firstColor).withAlphaComponent(0.3).cgColor
                }
                
            }
            gradient.startPoint = CGPoint(x: 0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1, y: 0.5)
            
            gradient.mask = rimLayer
            rimLayer.backgroundColor = UIColor.clear.cgColor
            rimLayer.borderColor = UIColor.black.cgColor
            
            layer.addSublayer(gradient)
        } else {
            if let firstColor = colors.first {
                rimLayer.backgroundColor = firstColor.copy(alpha: 0.3)
                rimLayer.borderColor = firstColor
                layer.addSublayer(rimLayer)
            }
        }
        
        let newView = UIView(frame: CGRect(x: component.x, y: component.y, width: component.width, height: component.height))
        self.drawingView.addSubview(newView)
        
        newView.layer.addSublayer(layer)
        newView.clipsToBounds = false
        
        let x = rimLayer.bounds.size.width / 2
        let y = rimLayer.bounds.size.height / 2
        
        if unsure {
            newView.alpha = 0.4
        }
        rimLayer.position = CGPoint(x: x, y: y)
        component.baseView = newView
        
        drawnHighlights[originalComponent] = newView
    }
}
