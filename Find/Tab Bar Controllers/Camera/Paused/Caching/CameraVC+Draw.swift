//
//  CameraVC+Draw.swift
//  Find
//
//  Created by Zheng on 1/25/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension CameraViewController {
    func drawHighlights(highlights: [Component]) {
        
        for component in highlights {
            DispatchQueue.main.async {
                
                let layer = CAShapeLayer()
                layer.frame = CGRect(x: 0, y: 0, width: component.width, height: component.height)
                layer.cornerRadius = component.height / 3.5
                
                let rimLayer = CALayer()
                rimLayer.bounds = layer.frame
                rimLayer.cornerRadius = component.height / 3.5
                rimLayer.borderWidth = 3
                
                guard let colors = self.matchToColors[component.text] else { return }
                if colors.count > 1 {
                    let gradient = CAGradientLayer()
                    gradient.frame = layer.bounds
                    if let gradientColors = self.matchToColors[component.text] {
                        let colors = gradientColors.map { $0.cgColor }
                        
                        gradient.colors = colors
                        if let firstColor = colors.first {
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
                        rimLayer.backgroundColor = firstColor.cgColor.copy(alpha: 0.3)
                        rimLayer.borderColor = firstColor.cgColor
                        layer.addSublayer(rimLayer)
                    }
                }
                
                let newView = UIView(frame: CGRect(x: component.x, y: component.y, width: component.width, height: component.height))
                newView.alpha = 0
                self.drawingView.addSubview(newView)
                
                newView.layer.addSublayer(layer)
                newView.clipsToBounds = false
                
                
                let x = rimLayer.bounds.size.width / 2
                let y = rimLayer.bounds.size.height / 2
                rimLayer.position = CGPoint(x: x, y: y)
                component.baseView = newView
                
                UIView.animate(withDuration: 0.15, animations: {
                    newView.alpha = 1
                })
                
            }
        }
    }
}
