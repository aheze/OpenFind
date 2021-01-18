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
    func drawHighlights() {
        print("image bounds: \(imageView.bounds)")
        print("draw boundsL \(drawingView.bounds)")
        
        let aspectFrame = AVMakeRect(aspectRatio: imageView.image?.size ?? imageView.frame.size, insideRect: contentView.frame)
        print("asp: \(aspectFrame)")
        
        drawingView.subviews.forEach({ $0.removeFromSuperview() })
        for comp in highlights {
            
            print("comp x: \(comp.x), y: \(comp.y)")
            
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
        print("hig count: \(drawnHighlights.count)")
        for (highlight, uiView) in drawnHighlights {
            print("looping")
            let aspectFrame = AVMakeRect(aspectRatio: imageView.image?.size ?? imageView.frame.size, insideRect: contentView.frame)
            print("asp: \(aspectFrame)")
            
            let newX = highlight.x * (aspectFrame.width) + aspectFrame.origin.x
            let newWidth = highlight.width * aspectFrame.width
            print("Y is \(aspectFrame.height + aspectFrame.origin.y)")
            let newY = highlight.y * (aspectFrame.height) + aspectFrame.origin.y
            let newHeight = highlight.height * aspectFrame.height
            
            uiView.frame = CGRect(x: newX, y: newY, width: newWidth, height: newHeight)
        }
    }
    
    func scaleInHighlight(originalComponent: Component, component: Component, unsure: Bool = false) {
        guard let colors = matchToColors[component.text] else { print("NO COLORS! scalee"); return }
        
//        DispatchQueue.main.async {
            
            let layer = CAShapeLayer()
            layer.frame = CGRect(x: 0, y: 0, width: component.width, height: component.height)
            layer.cornerRadius = component.height / 3.5
            
            let newLayer = CAShapeLayer()
            newLayer.bounds = layer.frame
            newLayer.path = UIBezierPath(roundedRect: layer.frame, cornerRadius: component.height / 3.5).cgPath
            newLayer.lineWidth = 3
            newLayer.lineCap = .round
            
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
            self.drawingView.addSubview(newView)
            
            newView.layer.addSublayer(layer)
            newView.clipsToBounds = false
          
            let x = newLayer.bounds.size.width / 2
            let y = newLayer.bounds.size.height / 2
            
            if unsure {
                newView.alpha = 0.4
            }
            newLayer.position = CGPoint(x: x, y: y)
            component.baseView = newView
            component.changed = true
            
            drawnHighlights[originalComponent] = newView
//        }
    }
}
