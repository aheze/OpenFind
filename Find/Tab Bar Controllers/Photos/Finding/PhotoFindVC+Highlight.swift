//
//  PhotoFindVC+Highlight.swift
//  Find
//
//  Created by Zheng on 1/16/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotoFindViewController {
    func addHighlight(text: String, rect: CGRect) -> UIView {
        var newOrigRect = rect
        newOrigRect.origin.x -= 1
        newOrigRect.origin.y -= 1
        newOrigRect.size.width += 2
        newOrigRect.size.height += 2
        
        let newView = UIView(frame: CGRect(x: newOrigRect.origin.x, y: newOrigRect.origin.y, width: newOrigRect.size.width, height: newOrigRect.size.height))
        guard let colors = matchToColors[text] else { return UIView() }
        
        let layer = CAShapeLayer()
        layer.frame = CGRect(x: 0, y: 0, width: newOrigRect.size.width, height: newOrigRect.size.height)
        layer.cornerRadius = rect.size.height / 3.5
        
        let newLayer = CAShapeLayer()
        newLayer.bounds = layer.frame
        newLayer.path = UIBezierPath(roundedRect: layer.frame, cornerRadius: newOrigRect.size.height / 3.5).cgPath
        newLayer.lineWidth = 0
        
        if colors.count > 1 {
            
            var newRect = layer.frame
            newRect.origin.x += 1
            newRect.origin.y += 1
            layer.frame.origin.x -= 1
            layer.frame.origin.y -= 1
            layer.frame.size.width += 2
            layer.frame.size.height += 2
            newLayer.path = UIBezierPath(roundedRect: newRect, cornerRadius: newOrigRect.size.height / 4.5).cgPath
            
            let gradient = CAGradientLayer()
            gradient.frame = layer.bounds
            gradient.colors = colors
            if let firstColor = colors.first {
                layer.backgroundColor = UIColor(cgColor: firstColor.cgColor).withAlphaComponent(0.3).cgColor
            }
            gradient.startPoint = CGPoint(x: 0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1, y: 0.5)
            gradient.mask = newLayer
            newLayer.fillColor = UIColor.clear.cgColor
            layer.addSublayer(gradient)
            
        } else {
            layer.addSublayer(newLayer)
            if let firstColor = colors.first {
                newLayer.fillColor = firstColor.cgColor.copy(alpha: 0.3)
                layer.addSublayer(newLayer)
            }
        }
        
        newView.layer.addSublayer(layer)
        newView.clipsToBounds = false
        let x = newLayer.bounds.size.width / 2
        let y = newLayer.bounds.size.height / 2
        newLayer.position = CGPoint(x: x, y: y)
        
        return newView
    }
}
