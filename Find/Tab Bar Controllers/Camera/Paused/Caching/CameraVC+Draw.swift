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
//    func drawHighlights(highlights: [Component]) {
//
//        for component in highlights {
//            DispatchQueue.main.async {
//                let cornerRadius = min(component.height / 3.5, 10)
//
//                let newView: CustomActionsView
//
//                guard let componentColors = self.matchToColors[component.text] else { return }
//                let gradientColors = componentColors.map { $0.cgColor }
//                let hexStrings = componentColors.map { $0.hexString }
//
//                if componentColors.count > 1 {
//                    let gradientView = GradientBorderView()
//
//                    gradientView.colors = gradientColors
//                    gradientView.cornerRadius = cornerRadius
//
//                    if let firstColor = gradientColors.first {
//                        gradientView.backgroundColor = UIColor(cgColor: firstColor).withAlphaComponent(0.3)
//                    }
//
//                    newView = gradientView
////                    let gradient = CAGradientLayer()
////                    gradient.frame = layer.bounds
////
////                    gradient.colors = gradientColors
////                    if let firstColor = gradientColors.first {
////                        layer.backgroundColor = UIColor(cgColor: firstColor).withAlphaComponent(0.3).cgColor
////                    }
////
////                    gradient.startPoint = CGPoint(x: 0, y: 0.5)
////                    gradient.endPoint = CGPoint(x: 1, y: 0.5)
////
////                    gradient.mask = rimLayer
////                    rimLayer.backgroundColor = UIColor.clear.cgColor
////                    rimLayer.borderColor = UIColor.black.cgColor
////
////                    layer.addSublayer(gradient)
//                } else {
//                    if let firstColor = gradientColors.first {
////                        rimLayer.backgroundColor = UIColor(cgColor: firstColor).withAlphaComponent(0.3)
////                        rimLayer.borderColor = firstColor.cgColor
////                        layer.addSublayer(rimLayer)
//                        newView.backgroundColor = UIColor(cgColor: firstColor).withAlphaComponent(0.3)
//                        newView.layer.borderColor = firstColor
//                        newView.layer.borderWidth = 3
//                        newView.layer.cornerRadius = cornerRadius
//                    }
//                }
//
//                component.baseView = newView
//                newView.frame = CGRect(x: component.x, y: component.y, width: component.width, height: component.height)
//
//                let newView = UIView(frame: CGRect(x: component.x, y: component.y, width: component.width, height: component.height))
//                newView.alpha = 0
//                self.drawingView.addSubview(newView)
//
//                newView.layer.addSublayer(layer)
//                newView.clipsToBounds = false
//
//                self.addAccessibilityLabel(component: component, newView: newView, hexString: hexStrings.first ?? "")
//
//
//                let x = rimLayer.bounds.size.width / 2
//                let y = rimLayer.bounds.size.height / 2
//                rimLayer.position = CGPoint(x: x, y: y)
//                component.baseView = newView
//
//                UIView.animate(withDuration: 0.15, animations: {
//                    newView.alpha = 1
//                })
//
//            }
//        }
//    }
}
