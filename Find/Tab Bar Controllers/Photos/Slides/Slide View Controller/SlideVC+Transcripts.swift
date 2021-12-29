//
//  SlideVC+Transcripts.swift
//  Find
//
//  Created by Zheng on 3/30/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import AVFoundation
import UIKit

extension SlideViewController {
    func resetTranscripts() {
        DispatchQueue.main.async {
            for subView in self.drawingView.subviews {
                subView.removeFromSuperview()
            }
            self.resultPhoto.transcripts.removeAll()
            self.showingTranscripts = false
        }
    }
    
    func drawAllTranscripts(focusedTranscript: Component? = nil, show: Bool) {
        if show {
            for subView in drawingView.subviews {
                subView.isHidden = true
            }
        }
        
        let aspectFrame = AVMakeRect(aspectRatio: imageView.image?.size ?? imageView.bounds.size, insideRect: contentView.bounds)
        
        for transcript in resultPhoto.transcripts {
            drawTranscript(component: transcript, aspectFrame: aspectFrame, show: show)
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
            for transcript in self.resultPhoto.transcripts {
                transcript.baseView?.isHidden = false
            }
            
            self.updateAccessibilityHints()
            
            if
                let focusedTranscript = focusedTranscript,
                let baseView = focusedTranscript.baseView
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    UIAccessibility.post(notification: .layoutChanged, argument: baseView)
                }
            }
        }
    }

    func showHighlights(currentTranscript: Component? = nil) {
        DispatchQueue.main.async {
            for subView in self.drawingView.subviews {
                subView.isHidden = true
            }
            for highlight in self.resultPhoto.components {
                highlight.baseView?.isHidden = false
            }
            
            self.updateAccessibilityHints()
            
            if
                let previousHighlight = self.previousActivatedHighlight,
                let baseView = previousHighlight.baseView
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    UIAccessibility.post(notification: .layoutChanged, argument: baseView)
                }
                self.previousActivatedHighlight = nil
                
            } else if currentTranscript != nil {
                var found = false
                for component in self.resultPhoto.components {
                    if component.transcriptComponent == currentTranscript {
                        if let baseView = component.baseView {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                UIAccessibility.post(notification: .layoutChanged, argument: baseView)
                            }
                        }
                        found = true
                        break
                    }
                }
                
                if !found {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        UIAccessibility.post(notification: .layoutChanged, argument: self.drawingBaseView)
                    }
                }
            }
        }
    }
    
    func drawTranscript(component: Component, aspectFrame: CGRect, show: Bool) {
        DispatchQueue.main.async {
            let cornerRadius = min(component.height / 5.5, 10)
            
            let transcriptColor = UIColor(hexString: "00AEEF")
            
            let newView = CustomActionsView()
            newView.backgroundColor = transcriptColor.withAlphaComponent(0.3)
            newView.layer.borderColor = transcriptColor.cgColor
            newView.layer.borderWidth = 1
            newView.layer.cornerRadius = cornerRadius
            
            let x = component.x * (aspectFrame.width) + aspectFrame.origin.x
            let w = component.width * aspectFrame.width
            let h = component.height * aspectFrame.height
            let y = (component.y * (aspectFrame.height) + aspectFrame.origin.y) - h
            
            component.baseView = newView
            newView.frame = CGRect(x: x, y: y, width: w, height: h)
            
            self.drawingView.addSubview(newView)
            
            self.addTranscriptAccessibility(component: component, newView: newView)
            
            if self.showingTranscripts {
                newView.accessibilityHint = "Double-tap to show highlights"
            } else {
                newView.accessibilityHint = "Double-tap to show transcript overlay"
            }
            
            newView.activated = { [weak self] in
                guard let self = self else { return false }
                
                self.showingTranscripts.toggle()
                if self.showingTranscripts {
                    self.showTranscripts()
                } else {
                    self.showHighlights(currentTranscript: component)
                }
                
                return true
            }
            
            newView.lostFocus = { [weak self] in
                guard let self = self else { return }

                self.previousActivatedHighlight = nil
            }
            
            newView.isHidden = !show
        }
    }
    
    func addTranscriptAccessibility(component: Component, newView: UIView) {
        /// speak contents
        var contents = [AccessibilityText]()
        for match in matchToColors {
            if component.text.contains(match.key) {
                if let pitch = match.value.first?.hexString.getDescription().1 {
                    let text = AccessibilityText(text: match.key, isRaised: false, customPitch: pitch)
                    contents.append(text)
                }
            }
        }
        
        let contentsTitle = AccessibilityText(text: " \nContains:\n", isRaised: true)
        
        let text = AccessibilityText(text: component.text, isRaised: false)
        let highlightText = AccessibilityText(text: " \nOverlay.\n", isRaised: false)
        let locationTitle = AccessibilityText(text: " \nLocation:\n", isRaised: true)
        
        let xPercent = Int(100 * (newView.frame.origin.x / contentView.bounds.width))
        let yPercent = Int(100 * (newView.frame.origin.y / contentView.bounds.height))
        let wPercent = Int(100 * (newView.bounds.width / contentView.bounds.width))
        let hPercent = Int(100 * (newView.bounds.height / contentView.bounds.height))
        
        let locationRawString = "\(xPercent) x, \(yPercent) y, \(wPercent) width, \(hPercent) height."
        let locationString = AccessibilityText(text: locationRawString, isRaised: false)
        
        newView.isAccessibilityElement = true
        
        let insetFrame = newView.frame.inset(by: UIEdgeInsets(top: -3, left: -3, bottom: -3, right: -3))
        newView.accessibilityFrame = insetFrame
        
        if contents.isEmpty {
            newView.accessibilityAttributedLabel = UIAccessibility.makeAttributedText([text, highlightText, locationTitle, locationString])
        } else {
            newView.accessibilityAttributedLabel = UIAccessibility.makeAttributedText([text, highlightText, contentsTitle] + contents + [locationTitle, locationString])
        }
    }
    
    func updateAccessibilityHints() {
        if findingActive || cameFromFind {
            if showingTranscripts {
                for highlight in resultPhoto.components {
                    highlight.baseView?.accessibilityHint = "Double-tap to show highlights"
                }
                for transcript in resultPhoto.transcripts {
                    transcript.baseView?.accessibilityHint = "Double-tap to show highlights"
                }
                drawingBaseView.accessibilityHint = "Showing transcript overlay (\(resultPhoto.transcripts.count) detected sentences). Double-tap to show highlights."
            } else {
                for highlight in resultPhoto.components {
                    highlight.baseView?.accessibilityHint = "Double-tap to show transcript overlay"
                }
                for transcript in resultPhoto.transcripts {
                    transcript.baseView?.accessibilityHint = "Double-tap to show transcript overlay"
                }
                drawingBaseView.accessibilityHint = "Showing \(resultPhoto.components.count) highlights. Double-tap to show transcript overlay."
            }
        } else {
            if showingTranscripts {
                for highlight in resultPhoto.components {
                    highlight.baseView?.accessibilityHint = "Showing transcript overlay. Double-tap to hide."
                }
                for transcript in resultPhoto.transcripts {
                    transcript.baseView?.accessibilityHint = "Showing transcript overlay. Double-tap to hide."
                }
                drawingBaseView.accessibilityHint = "Showing transcript overlay (\(resultPhoto.transcripts.count) detected sentences). Double-tap to hide."
            } else {
                for highlight in resultPhoto.components {
                    highlight.baseView?.accessibilityHint = "Double-tap to show transcript overlay"
                }
                for transcript in resultPhoto.transcripts {
                    transcript.baseView?.accessibilityHint = "Double-tap to show transcript overlay"
                }
                drawingBaseView.accessibilityHint = "Double-tap to show transcript overlay"
            }
        }
    }
}
