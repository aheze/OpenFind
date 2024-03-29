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
            let topContentFrame = topGroupView.convert(topGroupView.bounds, to: nil)
            let passthroughFrame = passthroughGroupView.convert(passthroughGroupView.bounds, to: nil)
            let highlightFrame = newView.convert(newView.bounds, to: nil)
            
            let drawingBounds = drawingView.bounds
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

                    if self.showingTranscripts {
                        newView.accessibilityHint = "Double-tap to show highlights"
                    } else {
                        newView.accessibilityHint = "Double-tap to show transcript overlay"
                    }
                    
                    newView.activated = { [weak self] in
                        guard let self = self else { return false }
                        
                        if CameraState.isPaused {
                            self.showingTranscripts.toggle()
                            if self.showingTranscripts {
                                self.showTranscripts(focusedTranscript: component.transcriptComponent)
                            } else {
                                self.showHighlights()
                            }
                            
                            self.previousActivatedHighlight = component
                            return true
                        }
                        
                        return false
                    }
                    
//                    let insetBounds = newView.bounds.inset(by: UIEdgeInsets(top: -6, left: -6, bottom: -6, right: -6))
//                    newView.accessibilityFrame = newView.convert(insetBounds, to: nil)
                    let insetFrame = newView.frame.inset(by: UIEdgeInsets(top: -6, left: -6, bottom: -6, right: -6))
                    newView.accessibilityFrame = insetFrame
                }
            }
        }
    }

    func updateAccessibilityFrames() {
        for highlight in currentComponents {
            if let baseView = highlight.baseView {
                let insetFrame = baseView.frame.inset(by: UIEdgeInsets(top: -6, left: -6, bottom: -6, right: -6))
                baseView.accessibilityFrame = insetFrame
            }
        }
    }
}
