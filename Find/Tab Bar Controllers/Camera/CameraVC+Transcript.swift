//
//  CameraVC+Transcript.swift
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
    func drawAllTranscripts() {
        transcriptsDrawn = true
        for subView in self.drawingView.subviews {
            subView.isHidden = true
        }
        for transcript in currentTranscriptComponents {
            drawTranscript(component: transcript)
        }
    }
    func showTranscripts() {
        DispatchQueue.main.async {
            for subView in self.drawingView.subviews {
                subView.isHidden = true
            }
            for transcript in self.currentTranscriptComponents {
                transcript.baseView?.isHidden = false
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
        }
    }
}
