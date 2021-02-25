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
            
            print("Should reset!!")
            resetHighlights()
        } else {
            guard let results = request?.results, results.count > 0 else {
                busyFastFinding = false
                return
            }
            if let currentMotion = motionManager.deviceMotion {
                motionXAsOfHighlightStart = Double(0)
                motionYAsOfHighlightStart = Double(0)
                motionZAsOfHighlightStart = Double(0)
                initialAttitude = currentMotion.attitude
            }
            
            for result in results {
                if let observation = result as? VNRecognizedTextObservation {
                    for text in observation.topCandidates(1) {
                        let component = Component()
                        component.x = observation.boundingBox.origin.x
                        component.y = 1 - observation.boundingBox.origin.y
                        component.height = observation.boundingBox.height
                        component.width = observation.boundingBox.width
                        let lowerCaseComponentText = text.string.lowercased()
                        component.text = lowerCaseComponentText
                        
                        let convertedOriginalWidthOfBigImage = self.aspectRatioWidthOverHeight * self.deviceSize.height
                        let offsetWidth = convertedOriginalWidthOfBigImage - self.deviceSize.width
                        let offHalf = offsetWidth / 2
                        let newW = component.width * convertedOriginalWidthOfBigImage
                        let newH = component.height * self.deviceSize.height
                        let newX = component.x * convertedOriginalWidthOfBigImage - offHalf
                        let newY = (component.y * self.deviceSize.height) - newH
                        let individualCharacterWidth = newW / CGFloat(component.text.count)
                        
                        component.x = newX
                        component.y = newY
                        component.width = newW
                        component.height = newH
                        if UserDefaults.standard.bool(forKey: "showTextDetectIndicator") {
                            drawFastHighlight(component: component)
                        }
                        for match in matchToColors.keys {
                            if lowerCaseComponentText.contains(match) {
                                let finalW = individualCharacterWidth * CGFloat(match.count)
                                
                                let indicies = component.text.indicesOf(string: match)
                                for index in indicies {
                                    let addedWidth = individualCharacterWidth * CGFloat(index)
                                    let finalX = newX + addedWidth
                                    let newComponent = Component()
                                    newComponent.x = finalX - 6
                                    newComponent.y = newY - 3
                                    newComponent.width = finalW + 12
                                    newComponent.height = newH + 6
                                    newComponent.text = match
                                    
                                    nextComponents.append(newComponent)
                                }
                            }
                        }
                    }
                }
            }
            
            busyFastFinding = false
            
            if CameraState.isPaused, cachePressed {
                addPausedFastResults()
                
            } else {
                animateFoundFastChange()
            }
//                    DispatchQueue.main.async {
////                        for subView in self.drawingView.subviews {
////                            subView.removeFromSuperview()
////                        }
//                        self.animateFoundFastChange()
//
////                        if self.howManyTimesFastFoundSincePaused >= 6 && self.nextComponents.count <= 2 {
////                            self.showCacheTip()
////                        }
////
////                        self.drawHighlights(highlights: self.nextComponents)
////                        self.updateMatchesNumber(to: self.nextComponents.count)
//                    }
//                } else {
//                    print("Found fast change")
//                    animateFoundFastChange()
////                    var componentsToAdd = [Component]()
////
////                    for nextComponent in nextComponents {
////                        var smallestDistance = CGFloat(999)
////
////                        for cachedComponent in highlightsFromCache {
////                            let point1 = CGPoint(x: cachedComponent.x + (cachedComponent.width / 2), y: cachedComponent.y + (cachedComponent.height / 2))
////                            let point2 = CGPoint(x: nextComponent.x + (nextComponent.width / 2), y: nextComponent.y + (nextComponent.height / 2))
////                            let pointDistance = relativeDistance(point1, point2)
////
////                            if pointDistance < smallestDistance {
////                                smallestDistance = pointDistance
////                            }
////
////                        }
////
////                        if smallestDistance >= 225 { ///Bigger, so add it
////                            componentsToAdd.append(nextComponent)
////                        }
////                    }
////
////                    drawHighlights(highlights: componentsToAdd)
////                    self.updateMatchesNumber(to: componentsToAdd.count + highlightsFromCache.count)
//                }
//            } else {
                
//            }
//            numberOfFastMatches = 0
            
        }
        
        if waitingToFind {
            waitingToFind = false
            findWhenPaused()
        }
    }
    
    func addPausedFastResults() {
        for newComponent in nextComponents {
            var lowestDist = CGFloat(10000)
            
            for oldComponent in currentComponents {
                
                if newComponent.text == oldComponent.text {
                    let currentCompPoint = CGPoint(x: oldComponent.x, y: oldComponent.y)
                    let nextCompPoint = CGPoint(x: newComponent.x, y: newComponent.y)
                    let distanceBetweenPoints = distance(currentCompPoint, nextCompPoint)
                    
                    if distanceBetweenPoints <= lowestDist {
                        lowestDist = distanceBetweenPoints
                    }
                }
            }

            if lowestDist >= 15 {
                currentComponents.append(newComponent)
                scaleInHighlight(component: newComponent)
            }
        }
        nextComponents.removeAll()
        tempComponents.removeAll()
    }
    
    func animateFoundFastChange() {
        
        for newComponent in nextComponents {
            
            var lowestDist = CGFloat(10000)
            var distToComp = [CGFloat: Component]()
            
            for oldComponent in currentComponents {
                if newComponent.text == oldComponent.text {
                    let currentCompPoint = CGPoint(x: oldComponent.x, y: oldComponent.y)
                    let nextCompPoint = CGPoint(x: newComponent.x, y: newComponent.y)
                    let distanceBetweenPoints = distance(currentCompPoint, nextCompPoint) //< 10
                    if distanceBetweenPoints <= lowestDist {
                        lowestDist = distanceBetweenPoints
                        distToComp[lowestDist] = oldComponent
                    }
                }
            }
            if lowestDist <= 15 {
                guard let oldComp = distToComp[lowestDist] else { print("NO COMP"); return }
                let newView = oldComp.baseView
                tempComponents.append(oldComp)
                DispatchQueue.main.async {
                    let rect = CGRect(x: newComponent.x, y: newComponent.y, width: newComponent.width, height: newComponent.height)
                    UIView.animate(withDuration: 0.5, animations: {
                        newView?.frame = rect
                    })
                }
            } else {
                scaleInHighlight(component: newComponent)
            }
        }
        for comp in currentComponents {
            if !tempComponents.contains(comp) {
                let theView = comp.baseView
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.2, animations: {
                            theView?.alpha = 0
                        }, completion: { _ in
                            theView?.isHidden = true
                            theView?.removeFromSuperview()
                        })
                    }
                })
            }
            
        }
        currentComponents.removeAll()
        currentComponents = tempComponents
        
        self.updateMatchesNumber(to: self.nextComponents.count)
        
        for next in nextComponents {
            if !tempComponents.contains(next) == true {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.3, animations: {
                            next.baseView?.alpha = 0
                        }, completion: { _ in
                            next.baseView?.isHidden = true
                            next.baseView?.removeFromSuperview()
                        })
                    }
                })
            }
        }
        
        nextComponents.removeAll()
        tempComponents.removeAll()
        
    }
    
    
    func scaleInHighlight(component: Component) {
        
        DispatchQueue.main.async {
            
            let layer = CAShapeLayer()
            layer.frame = CGRect(x: 0, y: 0, width: component.width, height: component.height)
            layer.cornerRadius = component.height / 3.5
            
            let newLayer = CAShapeLayer()
            newLayer.bounds = layer.frame
            newLayer.path = UIBezierPath(roundedRect: layer.frame, cornerRadius: component.height / 3.5).cgPath
            newLayer.lineWidth = 3
            newLayer.lineCap = .round
            
            guard let colors = self.matchToColors[component.text] else { print("NO COLORS! scalee"); return }
            if colors.count > 1 {
                var newRect = layer.frame
                newRect.origin.x += 1.5
                newRect.origin.y += 1.5
                layer.frame.origin.x -= 1.5
                layer.frame.origin.y -= 1.5
                layer.frame.size.width += 3
                layer.frame.size.height += 3
                newLayer.path = UIBezierPath(roundedRect: newRect, cornerRadius: component.height / 4.5).cgPath
                let gradient = CAGradientLayer()
                gradient.frame = layer.bounds
                if let gradientColors = self.matchToColors[component.text] {
                    gradient.colors = gradientColors
                    if let firstColor = gradientColors.first {
                        layer.backgroundColor = UIColor(cgColor: firstColor).withAlphaComponent(0.3).cgColor
                    }
                }
                gradient.startPoint = CGPoint(x: 0, y: 0.5)
                gradient.endPoint = CGPoint(x: 1, y: 0.5)
                
                gradient.mask = newLayer
                newLayer.fillColor = UIColor.clear.cgColor
                newLayer.strokeColor = UIColor.black.cgColor
                
                layer.addSublayer(gradient)
            } else {
                if let firstColor = colors.first {
                    newLayer.fillColor = firstColor.copy(alpha: 0.3)
                    newLayer.strokeColor = firstColor
                    layer.addSublayer(newLayer)
                }
            }
            
            let newView = UIView(frame: CGRect(x: component.x, y: component.y, width: component.width, height: component.height))
            newView.alpha = 0
            self.drawingView.addSubview(newView)
            
            newView.layer.addSublayer(layer)
            newView.clipsToBounds = false
            
            
            let x = newLayer.bounds.size.width / 2
            let y = newLayer.bounds.size.height / 2
            newLayer.position = CGPoint(x: x, y: y)
            component.baseView = newView
            
            UIView.animate(withDuration: 0.15, animations: {
                newView.alpha = 1
            })
            if self.nextComponents.count > self.previousNumberOfMatches {
                let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
                strokeAnimation.fromValue = 0
                strokeAnimation.toValue = 1
                strokeAnimation.duration = 0.3
                strokeAnimation.autoreverses = false
                strokeAnimation.repeatCount = 0
                newLayer.add(strokeAnimation, forKey: "line")
                self.layerScaleAnimation(layer: newLayer, duration: 0.2, fromValue: 1.2, toValue: 1)
            }
            
        }
        self.tempComponents.append(component)
    }
    
    func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt(xDist * xDist + yDist * yDist))
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
    func drawFastHighlight(component: Component) {
        DispatchQueue.main.async {
            
            let newW = component.width
            let newH = component.height
            
            let buffer = CGFloat(3)
            let doubBuffer = CGFloat(6)
            let newX = component.x
            let newY = component.y
            let layer = CAShapeLayer()
            layer.frame = CGRect(x: newX - buffer, y: newY, width: newW + doubBuffer, height: newH)
            layer.cornerRadius = newH / 3.5
            self.animateFastChange(layer: layer)
        }
    }
    func resetHighlights(updateMatchesLabel: Bool = true) {
        currentComponents.removeAll()
        nextComponents.removeAll()
        tempComponents.removeAll()
        
        DispatchQueue.main.async {
            if updateMatchesLabel, self.currentComponents.count == 0 { /// make sure is still 0, because async can run late
                self.updateMatchesNumber(to: 0)
            }
            for subView in self.drawingView.subviews {
                subView.removeFromSuperview()
            }
        }
        
    }
    func animateFastChange(layer: CAShapeLayer) {
        drawingView.layer.addSublayer(layer)
        layer.masksToBounds = true
        let gradient = CAGradientLayer()
        gradient.frame = layer.bounds
        gradient.colors = [#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor, #colorLiteral(red: 0.7220415609, green: 0.7220415609, blue: 0.7220415609, alpha: 0.3010059932).cgColor, #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor]
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

