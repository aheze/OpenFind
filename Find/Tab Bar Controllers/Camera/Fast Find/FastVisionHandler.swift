//
//  FastVisionHandler.swift
//  Find
//
//  Created by Andrew on 12/21/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit
import Vision
import ARKit
import CoreMotion

extension CameraViewController {
    
    func handleFastDetectedText(request: VNRequest?, error: Error?) {
        if shouldResetHighlights {
            
            /// reset the cycle
            busyFastFinding = false
            resetHighlights()
        } else {
            if currentPassCount >= 80 {
                canNotify = true
            }
            
            if let results = request?.results, results.count > 0 {
                
                if let currentMotion = motionManager.deviceMotion {
                    motionXAsOfHighlightStart = Double(0)
                    motionYAsOfHighlightStart = Double(0)
                    motionZAsOfHighlightStart = Double(0)
                    initialAttitude = currentMotion.attitude
                }
                
                DispatchQueue.main.async {
                    
                    var newComponents = [Component]()
                    
                    for result in results {
                        if let observation = result as? VNRecognizedTextObservation {
                            let convertedRect = self.getConvertedRect(
                                boundingBox: observation.boundingBox,
                                inImage: self.pixelBufferSize,
                                containedIn: self.cameraView.bounds.size
                            )
                            
                            if UserDefaults.standard.bool(forKey: "showTextDetectIndicator") {
                                let detectionRect = convertedRect.inset(by: UIEdgeInsets(top: -3, left: -3, bottom: -3, right: -3))
                                self.animateDetection(rect: detectionRect)
                            }
                            
                            
                            for text in observation.topCandidates(1) {
                                
                                let individualCharacterWidth = convertedRect.width / CGFloat(text.string.count)
                                let lowercaseText = text.string.lowercased()
                                
                                for match in self.matchToColors.keys {
                                    if lowercaseText.contains(match) {
                                        
                                        let indices = lowercaseText.indicesOf(string: match)
                                        for index in indices {
                                            let x = convertedRect.origin.x + (individualCharacterWidth * CGFloat(index))
                                            let y = convertedRect.origin.y
                                            let width = (individualCharacterWidth * CGFloat(match.count))
                                            let height = convertedRect.height
                                            
                                            let component = Component()
                                            component.x = x - 6
                                            component.y = y - 3
                                            component.width = width + 12
                                            component.height = height + 12
                                            component.text = match.lowercased()
                                            
                                            newComponents.append(component)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    if newComponents.isEmpty {
                        self.resetHighlights(updateMatchesLabel: true)
                    } else {
                        
                        if CameraState.isPaused, self.cachePressed {
                            self.addPausedFastResults(newComponents: newComponents)
                        } else {
                            let finalizeNotify = (newComponents.count > self.currentComponents.count && self.canNotify)
                            self.animateNewHighlights(newComponents: newComponents, shouldScale: finalizeNotify)
                            
                            if finalizeNotify {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.prepare()
                                generator.impactOccurred()
                                
                                self.canNotify = false
                                self.currentPassCount = 0
                            }
                        }
                    }
                    
                    self.busyFastFinding = false
                }
                
            } else {
                self.resetHighlights(updateMatchesLabel: true)
                busyFastFinding = false
            }
        }
        
        if waitingToFind {
            waitingToFind = false
            findWhenPaused()
        }
    }
    
    func addPausedFastResults(newComponents: [Component]) {
        for newComponent in newComponents {
            var lowestDistance = CGFloat(10000)
            
            for oldComponent in currentComponents {
                
                if newComponent.text == oldComponent.text {
                    let currentCompPoint = CGPoint(x: oldComponent.x, y: oldComponent.y)
                    let nextCompPoint = CGPoint(x: newComponent.x, y: newComponent.y)
                    let distanceBetweenPoints = relativeDistance(currentCompPoint, nextCompPoint)
                    
                    if distanceBetweenPoints <= lowestDistance {
                        lowestDistance = distanceBetweenPoints
                    }
                }
            }
            
            if lowestDistance >= 144 {
                currentComponents.append(newComponent)
                scaleInHighlight(component: newComponent, shouldScale: false)
            }
        }
    }
    
    func animateNewHighlights(newComponents: [Component], shouldScale: Bool) {
        
        var animatedComponents = [Component]()
        var nextComponents = [Component]()
        
        for newComponent in newComponents {
            
            var lowestDistance = CGFloat(10000)
            var lowestComponent: Component?
            
            for oldComponent in currentComponents {
                if newComponent.text == oldComponent.text {
                    let currentCompPoint = CGPoint(x: oldComponent.x, y: oldComponent.y)
                    let nextCompPoint = CGPoint(x: newComponent.x, y: newComponent.y)
                    let distanceBetweenPoints = relativeDistance(currentCompPoint, nextCompPoint)
                    if distanceBetweenPoints <= lowestDistance {
                        lowestDistance = distanceBetweenPoints
                        lowestComponent = oldComponent
                    }
                }
            }
            
            if
                lowestDistance <= 144,
                let lowestComponent = lowestComponent
            {
                animatedComponents.append(lowestComponent)
                
                let newView = lowestComponent.baseView
                let rect = CGRect(x: newComponent.x, y: newComponent.y, width: newComponent.width, height: newComponent.height)
                
                UIView.animate(withDuration: 0.5) {
                    newView?.frame = rect
                }
                nextComponents.append(lowestComponent)
            } else {
                scaleInHighlight(component: newComponent, shouldScale: shouldScale)
                nextComponents.append(newComponent)
            }
        }
        
        for oldComponent in currentComponents {
            if !animatedComponents.contains(oldComponent) {
                let baseView = oldComponent.baseView
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.2) {
                            baseView?.alpha = 0
                        } completion: { _ in
                            baseView?.removeFromSuperview()
                        }
                    }
                }
            }
        }
        currentComponents = nextComponents
    }
    
    func scaleInHighlight(component: Component, shouldScale: Bool) {
        DispatchQueue.main.async {
            let cornerRadius = min(component.height / 3.5, 10)
            
            let newView: UIView
            
            guard let colors = self.matchToColors[component.text] else { return }
            
            
            if colors.count > 1 {
                let gradientView = GradientView()
                if let gradientColors = self.matchToColors[component.text] {
                    gradientView.colors = gradientColors
                    gradientView.cornerRadius = cornerRadius
                    
                    if let firstColor = gradientColors.first {
                        gradientView.backgroundColor = UIColor(cgColor: firstColor).withAlphaComponent(0.3)
                    }
                }
                newView = gradientView
            } else {
                newView = UIView()
                if let gradientColors = self.matchToColors[component.text] {
                    if let firstColor = gradientColors.first {
                        newView.backgroundColor = UIColor(cgColor: firstColor).withAlphaComponent(0.3)
                    }
                }
                if let firstColor = colors.first {
                    newView.backgroundColor = UIColor(cgColor: firstColor).withAlphaComponent(0.3)
                    newView.layer.borderColor = firstColor
                    newView.layer.borderWidth = 3
                    newView.layer.cornerRadius = cornerRadius
                }
            }
            
            newView.frame = CGRect(x: component.x, y: component.y, width: component.width, height: component.height)
//            print("rect.. \(CGRect(x: component.x, y: component.y, width: component.width, height: component.height))")
            newView.alpha = 0
            component.baseView = newView
            
            self.drawingView.addSubview(newView)
            
            if shouldScale {
                newView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }
            
            UIView.animate(withDuration: 0.15) {
                newView.alpha = 1
                if shouldScale {
                    newView.transform = CGAffineTransform.identity
                }
            }
        }
    }
    
    func layerScaleAnimation(layer: CALayer, duration: CFTimeInterval, fromValue: CGFloat, toValue: CGFloat) {
        let timing = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        let scaleAnimation: CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        CATransaction.begin()
        CATransaction.setAnimationTimingFunction(timing)
        scaleAnimation.duration = duration
        scaleAnimation.fromValue = fromValue
        scaleAnimation.toValue = toValue
        layer.add(scaleAnimation, forKey: "scale")
        CATransaction.commit()
    }
    func resetHighlights(updateMatchesLabel: Bool = true) {
        currentComponents.removeAll()
        
        DispatchQueue.main.async {
            if updateMatchesLabel, self.currentComponents.count == 0 { /// make sure is still 0, because async can run late
                self.updateMatchesNumber(to: 0)
            }
            for subView in self.drawingView.subviews {
                subView.removeFromSuperview()
            }
        }
        
    }
    func animateDetection(rect: CGRect) {
        let layer = CAShapeLayer()
        layer.frame = rect
        layer.cornerRadius = min(rect.height / 5, 10)
        
        drawingView.layer.addSublayer(layer)
        layer.masksToBounds = true
        let gradient = CAGradientLayer()
        gradient.frame = layer.bounds
        gradient.colors = [#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor, #colorLiteral(red: 0, green: 0.6823529412, blue: 0.937254902, alpha: 0.1).cgColor, #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor]
        gradient.startPoint = CGPoint(x: -1, y: 0.5)
        gradient.endPoint = CGPoint(x: 0, y: 0.5)
        layer.addSublayer(gradient)
        
        let startPointAnim = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.startPoint))
        startPointAnim.fromValue = CGPoint(x: -1, y: 0.5)
        startPointAnim.toValue = CGPoint(x:1, y: 0.5)
        
        let endPointAnim = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.endPoint))
        endPointAnim.fromValue = CGPoint(x: 0, y: 0.5)
        endPointAnim.toValue = CGPoint(x:2, y: 0.5)
        
        let animGroup = CAAnimationGroup()
        animGroup.animations = [startPointAnim, endPointAnim]
        animGroup.duration = 0.6
        animGroup.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        animGroup.repeatCount = 0
        gradient.add(animGroup, forKey: "animateGrad")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            layer.removeFromSuperlayer()
        })
    }
}
extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        guard let index = firstIndex(of: object) else {return}
        remove(at: index)
    }
}
extension String {
    func indicesOf(string: String) -> [Int] {
        var indices = [Int]()
        var searchStartIndex = self.startIndex
        
        while searchStartIndex < self.endIndex,
              let range = self.range(of: string, range: searchStartIndex..<self.endIndex),
              !range.isEmpty
        {
            let index = distance(from: self.startIndex, to: range.lowerBound)
            indices.append(index)
            searchStartIndex = range.upperBound
        }
        
        return indices
    }
}

