//
//  HighlightAccessibility.swift
//  Find
//
//  Created by Zheng on 3/29/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension CameraViewController {
    
    /// newView = view of highlight component
    func addAccessibilityLabel(component: Component, newView: CustomActionsView, hexString: String) {
        if UIAccessibility.isVoiceOverRunning {
            let topContentFrame = self.topContentView.convert(self.topContentView.bounds, to: nil)
            let passthroughFrame = self.passthroughView.convert(self.passthroughView.bounds, to: nil)
            let highlightFrame = newView.convert(newView.bounds, to: nil)
            
            let drawingBounds = self.drawingView.bounds
            DispatchQueue.global(qos: .userInitiated).async {
                var overlapString = AccessibilityText(text: "", isRaised: false)
                if topContentFrame.intersects(highlightFrame) {
                    overlapString = AccessibilityText(text: "\nPartially covered underneath search controls.", isRaised: false)
                } else if passthroughFrame.intersects(highlightFrame) {
                    overlapString = AccessibilityText(text: "\nPartially covered underneath camera controls.", isRaised: false)
                }
                
                let text = AccessibilityText(text: component.text, isRaised: false, customPitch: hexString.getDescription().1)
                let highlightText = AccessibilityText(text: "\nHighlight.\n", isRaised: false)
                let locationTitle = AccessibilityText(text: "Location:", isRaised: true)
                
                let xPercent = Int(100 * ((component.x + (component.width / 2)) / drawingBounds.width))
                let yPercent = Int(100 * ((component.y + (component.height / 2)) / drawingBounds.height))
                
                let locationRawString = "\(xPercent) x, \(yPercent) y"
                let locationString = AccessibilityText(text: locationRawString, isRaised: false)
                
                DispatchQueue.main.async {
                    newView.isAccessibilityElement = true
                    newView.accessibilityAttributedLabel = UIAccessibility.makeAttributedText([text, highlightText, locationTitle, locationString, overlapString])
                    newView.accessibilityHint = "(0 x, 0 y) is at top-left of screen. (100 x, 100 y) is at bottom-right."
                    
                    newView.actions = [
                        
                        UIAccessibilityCustomAction(name: "Show transcript overlay") { _ in
                            print("overlay from higlight")
                            self.showingTranscripts.toggle()
                            if self.showingTranscripts {
                                if !self.transcriptsDrawn {
                                    self.drawAllTranscripts()
                                }
                                self.showTranscripts()
                            } else {
                                self.showHighlights()
                            }
                            return true
                        },
                        
                        UIAccessibilityCustomAction(name: "Focus VoiceOver on shutter button") { _ in
                            UIAccessibility.post(notification: .layoutChanged, argument: self.cameraIconHolder)
                            return true
                        }
                    ]
                    
                    let insetBounds = newView.bounds.inset(by: UIEdgeInsets(top: -6, left: -6, bottom: -6, right: -6))
                    newView.accessibilityFrame = newView.convert(insetBounds, to: nil)
                }
            }
        }
    }
}
