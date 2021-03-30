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
        drawingView?.subviews.forEach({ $0.removeFromSuperview() })
    }
    func drawHighlights() {
        removeAllHighlights()
        
        let aspectFrame = AVMakeRect(aspectRatio: imageView.image?.size ?? imageView.bounds.size, insideRect: contentView.bounds)
        for component in resultPhoto.components {
            scaleInHighlight(component: component, aspectFrame: aspectFrame)
        }
    }
    
    func updateHighlightFrames() {
        let aspectFrame = AVMakeRect(aspectRatio: imageView.image?.size ?? imageView.bounds.size, insideRect: contentView.bounds)
        
        for highlight in resultPhoto.components {
            let newX = highlight.x * (aspectFrame.width) + aspectFrame.origin.x - 6
            let newY = highlight.y * (aspectFrame.height) + aspectFrame.origin.y - 3
            let newWidth = highlight.width * aspectFrame.width + 12
            let newHeight = highlight.height * aspectFrame.height + 6
            
            highlight.baseView?.frame = CGRect(x: newX, y: newY, width: newWidth, height: newHeight)
        }
        
        for transcript in resultPhoto.transcripts {
            let x = transcript.x * (aspectFrame.width) + aspectFrame.origin.x
            let w = transcript.width * aspectFrame.width
            let h = transcript.height * aspectFrame.height
            let y = (transcript.y * (aspectFrame.height) + aspectFrame.origin.y) - h
            
            transcript.baseView?.frame = CGRect(x: x, y: y, width: w, height: h)
        }
    }
    
    func scaleInHighlight(component: Component, aspectFrame: CGRect) {
        component.printDescription()
        
        let newX = component.x * (aspectFrame.width) + aspectFrame.origin.x - 6
        let newY = component.y * (aspectFrame.height) + aspectFrame.origin.y - 3
        let newWidth = component.width * aspectFrame.width + 12
        let newHeight = component.height * aspectFrame.height + 6
        
        let cornerRadius = min(newHeight / 3.5, 10)
        
        let newView: CustomActionsView
        
        guard let componentColors = self.matchToColors[component.text] else { return }
        let gradientColors = componentColors.map { $0.cgColor }
        let hexStrings = componentColors.map { $0.hexString }
        
        if componentColors.count > 1 {
            let gradientView = GradientBorderView()
            
            gradientView.colors = gradientColors
            gradientView.cornerRadius = cornerRadius
            
            if let firstColor = gradientColors.first {
                gradientView.backgroundColor = UIColor(cgColor: firstColor).withAlphaComponent(0.3)
            }
            
            newView = gradientView
        } else {
            newView = CustomActionsView()
            
            if let firstColor = gradientColors.first {
                newView.backgroundColor = UIColor(cgColor: firstColor).withAlphaComponent(0.3)
                newView.layer.borderColor = firstColor
                newView.layer.borderWidth = 3
                newView.layer.cornerRadius = cornerRadius
            }
        }
        
        component.baseView = newView
        newView.frame = CGRect(x: newX, y: newY, width: newWidth, height: newHeight)
        
        self.drawingView.addSubview(newView)
        
        if newHeight > 50 {
            newView.alpha = 0.4
        }
        
        component.baseView = newView
    }
}
