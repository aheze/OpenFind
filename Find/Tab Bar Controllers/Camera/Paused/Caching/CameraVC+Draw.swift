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
                
                let newLayer = CAShapeLayer()
                newLayer.bounds = layer.frame
                newLayer.path = UIBezierPath(roundedRect: layer.frame, cornerRadius: component.height / 3.5).cgPath
                newLayer.lineWidth = 3
                newLayer.lineCap = .round
                
                guard let colors = self.matchToColors[component.text] else { print("NO COLORS! scalee"); return }
                if colors.count > 1 {
                    var newRect = layer.frame
                    newRect.origin.x += 1.5
                    newRect.origin.y += 1.5
                    layer.frame.origin.x -= 1.5
                    layer.frame.origin.y -= 1.5
                    layer.frame.size.width += 3
                    layer.frame.size.height += 3
                    newLayer.path = UIBezierPath(roundedRect: newRect, cornerRadius: component.height / 4.5).cgPath
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
                    
                    gradient.mask = newLayer
                    newLayer.fillColor = UIColor.clear.cgColor
                    newLayer.strokeColor = UIColor.black.cgColor
                    
                    layer.addSublayer(gradient)
                } else {
                    if let firstColor = colors.first {
                        newLayer.fillColor = firstColor.copy(alpha: 0.3)
                        newLayer.strokeColor = firstColor
                        layer.addSublayer(newLayer)
                    }
                }
                
                let newView = UIView(frame: CGRect(x: component.x, y: component.y, width: component.width, height: component.height))
                newView.alpha = 0
                self.drawingView.addSubview(newView)
                
                newView.layer.addSublayer(layer)
                newView.clipsToBounds = false
                
                
                let x = newLayer.bounds.size.width / 2
                let y = newLayer.bounds.size.height / 2
                newLayer.position = CGPoint(x: x, y: y)
                component.baseView = newView
                component.changed = true
                
                UIView.animate(withDuration: 0.15, animations: {
                    newView.alpha = 1
                })
                
            }
        }
    }
}
