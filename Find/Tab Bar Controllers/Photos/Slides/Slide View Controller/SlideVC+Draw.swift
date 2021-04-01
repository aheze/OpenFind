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
            
            let newFrame = CGRect(x: newX, y: newY, width: newWidth, height: newHeight)
            highlight.baseView?.frame = newFrame
            
            if let baseView = highlight.baseView {
                guard let componentColors = self.matchToColors[highlight.text] else { return }
                
                addAccessibilityLabel(component: highlight, newView: baseView, hexString: componentColors.first?.hexString ?? "")
            }
        }
        
        for transcript in resultPhoto.transcripts {
            let x = transcript.x * (aspectFrame.width) + aspectFrame.origin.x
            let w = transcript.width * aspectFrame.width
            let h = transcript.height * aspectFrame.height
            let y = (transcript.y * (aspectFrame.height) + aspectFrame.origin.y) - h
            
            let newFrame = CGRect(x: x, y: y, width: w, height: h)
            transcript.baseView?.frame = newFrame
            
            if let baseView = transcript.baseView {
                self.addTranscriptAccessibility(component: transcript, newView: baseView)
            }
        }
    }
    
    func scaleInHighlight(component: Component, aspectFrame: CGRect) {
        
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
        
        
        addAccessibilityLabel(component: component, newView: newView, hexString: hexStrings.first ?? "")
        
        if newHeight > 50 {
            newView.alpha = 0.4
        }
    }
    
    func addAccessibilityLabel(component: Component, newView: CustomActionsView, hexString: String) {
        if UIAccessibility.isVoiceOverRunning {
            
            var overlapString = AccessibilityText(text: "", isRaised: false)
            if !cameFromFind {
                if let navigationBar = self.navigationController?.navigationBar {
                    
                    let navigationBarFrame = navigationBar.convert(navigationBar.bounds, to: nil)
                    let tabBarFrame = ConstantVars.getTabBarFrame?() ?? CGRect.zero
                    
                    if navigationBarFrame.intersects(newView.frame) {
                        overlapString = AccessibilityText(text: "\nPartially covered underneath navigation bar", isRaised: false)
                    } else if tabBarFrame.intersects(newView.frame) {
                        overlapString = AccessibilityText(text: "\nPartially covered underneath toolbar", isRaised: false)
                    }
                }
            }
            
            let text = AccessibilityText(text: component.text, isRaised: false, customPitch: hexString.getDescription().1)
            let highlightText = AccessibilityText(text: "\nHighlight.\n", isRaised: false)
            let locationTitle = AccessibilityText(text: "Location:", isRaised: true)
            
            let xPoint = newView.frame.origin.x + (newView.frame.width / 2)
            let yPoint = newView.frame.origin.y + (newView.frame.height / 2)
            
            let xPercent = Int(100 * (xPoint / contentView.bounds.width))
            let yPercent = Int(100 * (yPoint / contentView.bounds.height))
            
            let locationRawString = "\(xPercent) x, \(yPercent) y"
            let locationString = AccessibilityText(text: locationRawString, isRaised: false)
            
            DispatchQueue.main.async {
                newView.isAccessibilityElement = true
                newView.accessibilityAttributedLabel = UIAccessibility.makeAttributedText([text, highlightText, locationTitle, locationString, overlapString])
                
                if self.showingTranscripts {
                    newView.accessibilityHint = "Double-tap to show highlights"
                } else {
                    newView.accessibilityHint = "Double-tap to show transcript overlay"
                }
                
                newView.activated = { [weak self] in
                    guard let self = self else { return false }
                    
                    self.showingTranscripts.toggle()
                    if self.showingTranscripts {
                        self.showTranscripts(focusedTranscript: component.transcriptComponent)
                    } else {
                        self.showHighlights()
                    }
                    
                    self.previousActivatedHighlight = component
                    
                    return true
                }
                
                let insetFrame = newView.frame.inset(by: UIEdgeInsets(top: -6, left: -6, bottom: -6, right: -6))
                newView.accessibilityFrame = insetFrame
            }
            
        }
    }
}
