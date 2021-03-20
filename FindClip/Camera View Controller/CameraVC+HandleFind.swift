//
//  CameraVC+HandleFind.swift
//  FindAppClip1
//
//  Created by Zheng on 3/14/21.
//

import UIKit
import Vision

extension CameraViewController {
    func handleFastDetectedText(request: VNRequest?, error: Error?) {
        
        if currentPassCount >= 80 {
            canNotify = true
        }
        
        if let results = request?.results, results.count > 0 {
            
            if let currentMotion = motionManager.deviceMotion {
                motionXAsOfHighlightStart = Double(0)
                motionYAsOfHighlightStart = Double(0)
                initialAttitude = currentMotion.attitude
            }
            
            DispatchQueue.main.async {
                
                var newComponents = [Component]()
                
                for result in results {
                    if let observation = result as? VNRecognizedTextObservation {
                        let convertedRect = self.getConvertedRect(
                            boundingBox: observation.boundingBox,
                            inImage: self.pixelBufferSize,
                            containedIn: self.cameraContentView.bounds.size
                        )
                        
                        let detectionRect = convertedRect.inset(by: UIEdgeInsets(top: -3, left: -3, bottom: -3, right: -3))
                        self.animateDetection(rect: detectionRect)
                        
                        /// just one string usually
                        for text in observation.topCandidates(1) {
                            
                            let individualCharacterWidth = convertedRect.width / CGFloat(text.string.count)
                            let lowercaseText = text.string.lowercased()
                            
                            if lowercaseText.contains(self.findText) {
                                let indices = lowercaseText.indicesOf(string: self.findText)
                                for index in indices {
                                    
                                    let x = convertedRect.origin.x + (individualCharacterWidth * CGFloat(index))
                                    let y = convertedRect.origin.y
                                    let width = (individualCharacterWidth * CGFloat(self.findText.count))
                                    let height = convertedRect.height
                                    
                                    let component = Component()
                                    component.x = x - 6
                                    component.y = y - 3
                                    component.width = width + 12
                                    component.height = height + 12
                                    component.text = text.string.lowercased()
                                    
                                    newComponents.append(component)
                                }
                            }
                        }
                    }
                }
                
                if newComponents.isEmpty {
                    self.removeCurrentComponents()
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
                
                
                self.busyFastFinding = false
            }
        } else {
            DispatchQueue.main.async {
                self.removeCurrentComponents()
            }
            busyFastFinding = false
        }
        
        if waitingToFind {
            waitingToFind = false
            findWhenPaused()
        }
    }
    
    func removeCurrentComponents() {
        for component in self.currentComponents {
            UIView.animate(withDuration: 0.2) {
                component.baseView?.alpha = 0
            } completion: { _ in
                component.baseView?.removeFromSuperview()
            }
        }
        self.currentComponents.removeAll()
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
            let highlightColor = UIColor(named: "100Blue")
            let newView = UIView(frame: CGRect(x: component.x, y: component.y, width: component.width, height: component.height))
            newView.backgroundColor = highlightColor?.withAlphaComponent(0.3)
            newView.layer.cornerRadius = cornerRadius
            newView.layer.borderWidth = 3
            newView.layer.borderColor = highlightColor?.cgColor
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
    
    func relativeDistance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(xDist * xDist + yDist * yDist)
    }
    
}

