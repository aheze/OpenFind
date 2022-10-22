//
//  CameraVC+Draw.swift
//  Find
//
//  Created by Zheng on 1/25/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension CameraViewController {
    func drawHighlights(highlights: [Component], shouldScale: Bool = false) {
        for highlight in highlights {
            scaleInHighlight(component: highlight, shouldScale: false)
        }
    }

    func scaleInHighlight(component: Component, shouldScale: Bool) {
        DispatchQueue.main.async {
            let cornerRadius = min(component.height / 3.5, 10)
            
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
            newView.frame = CGRect(x: component.x, y: component.y, width: component.width, height: component.height)
            newView.alpha = 0
            
            self.drawingView.addSubview(newView)
            
            if CameraState.isPaused {
                self.addAccessibilityLabel(component: component, newView: newView, hexString: hexStrings.first ?? "")
            }
            
            if shouldScale {
                newView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }
            UIView.animate(withDuration: 0.15) {
                newView.alpha = 1
                if shouldScale {
                    newView.transform = CGAffineTransform.identity
                }
            }
            
            if self.showingTranscripts {
                newView.isHidden = true
            }
        }
    }
}
