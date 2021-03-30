//
//  CameraVC+Transcripts.swift
//  Find
//
//  Created by Zheng on 3/30/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension CameraViewController {
    func resetTranscripts() {
        DispatchQueue.main.async {
            for subView in self.drawingView.subviews {
                subView.removeFromSuperview()
            }
            self.currentTranscriptComponents.removeAll()
            self.transcriptsDrawn = false
        }
    }
    func drawAllTranscripts(focusedTranscript: Component? = nil) {
        transcriptsDrawn = true
        for subView in self.drawingView.subviews {
            subView.isHidden = true
        }
        for transcript in currentTranscriptComponents {
            drawTranscript(component: transcript)
        }
        updateAccessibilityHints()
        
        if
            let focusedTranscript = focusedTranscript,
            let baseView = focusedTranscript.baseView
        {
            UIAccessibility.post(notification: .layoutChanged, argument: baseView)
        }
    }
    
    
    /// toggling
    func showTranscripts(focusedTranscript: Component? = nil) {
        DispatchQueue.main.async {
            for subView in self.drawingView.subviews {
                subView.isHidden = true
            }
            for transcript in self.currentTranscriptComponents {
                transcript.baseView?.isHidden = false
            }
            self.updateAccessibilityHints()
            
            if
                let focusedTranscript = focusedTranscript,
                let baseView =  focusedTranscript.baseView
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    UIAccessibility.post(notification: .layoutChanged, argument: baseView)
                }
            }
        }
    }
    func showHighlights() {
        DispatchQueue.main.async {
            for subView in self.drawingView.subviews {
                subView.isHidden = true
            }
            for highlight in self.currentComponents {
                highlight.baseView?.isHidden = false
            }
            self.updateAccessibilityHints()
            
            if
                let previousHighlight = self.previousActivatedHighlight,
                let baseView =  previousHighlight.baseView
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    UIAccessibility.post(notification: .layoutChanged, argument: baseView)
                }
                self.previousActivatedHighlight = nil
            }
        }
    }
    
    
    func drawTranscript(component: Component) {
        DispatchQueue.main.async {
            let cornerRadius = min(component.height / 5.5, 10)
            
            let transcriptColor = UIColor(hexString: "00AEEF")
            
            let newView = CustomActionsView()
            newView.backgroundColor = transcriptColor.withAlphaComponent(0.3)
            newView.layer.borderColor = transcriptColor.cgColor
            newView.layer.borderWidth = 1
            newView.layer.cornerRadius = cornerRadius
            
            component.baseView = newView
            newView.frame = CGRect(x: component.x, y: component.y, width: component.width, height: component.height)
            self.drawingView.addSubview(newView)
            
            let topContentFrame = self.topContentView.convert(self.topContentView.bounds, to: nil)
            let passthroughFrame = self.passthroughView.convert(self.passthroughView.bounds, to: nil)
            let highlightFrame = newView.convert(newView.bounds, to: nil)
            
            
            let drawingBounds = self.drawingView.bounds
            
            var overlapString = AccessibilityText(text: "", isRaised: false)
            if topContentFrame.intersects(highlightFrame) {
                overlapString = AccessibilityText(text: "\nPartially covered underneath search controls.", isRaised: false)
            } else if passthroughFrame.intersects(highlightFrame) {
                overlapString = AccessibilityText(text: "\nPartially covered underneath camera controls.", isRaised: false)
            }
            
            let text = AccessibilityText(text: component.text, isRaised: false)
            let highlightText = AccessibilityText(text: "\nOverlay.\n", isRaised: false)
            let locationTitle = AccessibilityText(text: "Location:", isRaised: true)
            
            let xPercent = Int(100 * (component.x / drawingBounds.width))
            let yPercent = Int(100 * (component.y / drawingBounds.height))
            let wPercent = Int(100 * (component.width / drawingBounds.width))
            let hPercent = Int(100 * (component.height / drawingBounds.height))
            
            
            let locationRawString = "\(xPercent) x, \(yPercent) y, \(wPercent) width, \(hPercent) height."
            let locationString = AccessibilityText(text: locationRawString, isRaised: false)
            
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
                        if !self.transcriptsDrawn {
                            self.drawAllTranscripts()
                        }
                        self.showTranscripts()
                    } else {
                        self.showHighlights()
                    }
                    
                    return true
                }
                
                return false
            }
        }
    }
}
