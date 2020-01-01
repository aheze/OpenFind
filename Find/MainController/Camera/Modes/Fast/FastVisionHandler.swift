//
//  FastVisionHandler.swift
//  Find
//
//  Created by Andrew on 12/21/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit
import Vision

extension ViewController {
    
    func handleFastDetectedText(request: VNRequest?, error: Error?) {
        numberCurrentFastmodePass += 1
        guard let results = request?.results, results.count > 0 else {
            //print("no results")
            return
        }
        
        for result in results {
            //numberOfFastMatches = 0
            //var foundAMatch = false
            if let observation = result as? VNRecognizedTextObservation {
               for text in observation.topCandidates(1) {
                    //print(text.string)
                    let component = Component()
                    component.x = observation.boundingBox.origin.x
                    component.y = 1 - observation.boundingBox.origin.y
                    component.height = observation.boundingBox.height
                    component.width = observation.boundingBox.width
                    component.text = text.string
                    drawFastHighlight(component: component)
                    if component.text.contains(finalTextToFind) {
                        //foundAMatch = true
                        let convertedOriginalWidthOfBigImage = self.aspectRatioWidthOverHeight * self.deviceSize.height
                        let offsetWidth = convertedOriginalWidthOfBigImage - self.deviceSize.width
                        let offHalf = offsetWidth / 2
                        let newW = component.width * convertedOriginalWidthOfBigImage
                        let newH = component.height * self.deviceSize.height
                        let newX = component.x * convertedOriginalWidthOfBigImage - offHalf
                        let newY = component.y * self.deviceSize.height
                        let individualCharacterWidth = newW / CGFloat(component.text.count)
                        let finalW = individualCharacterWidth * CGFloat(finalTextToFind.count)
                        
                        let indicies = component.text.indicesOf(string: finalTextToFind)
                        for index in indicies {
                            let addedWidth = individualCharacterWidth * CGFloat(index)
                            let finalX = newX + addedWidth
                            let newComponent = Component()
                            newComponent.x = finalX
                            newComponent.y = newY
                            newComponent.width = finalW
                            newComponent.height = newH
                            newComponent.text = "This value is not needed"
                            nextComponents.append(newComponent)
                            
                        }
                    }
                
                }
            }
            
        }
        animateFoundFastChange()
        numberOfFastMatches = 0
    }
    
    
    func scaleInHighlight(component: Component) {
        DispatchQueue.main.async {
            print("scale")
            
            let layer = CAShapeLayer()
            layer.frame = CGRect(x: 0, y: 0, width: component.width, height: component.height)
            layer.cornerRadius = component.height / 3.5
            
            let newLayer = CAShapeLayer()
            newLayer.bounds = layer.frame
            newLayer.path = UIBezierPath(roundedRect: layer.frame, cornerRadius: component.height / 3.5).cgPath
            newLayer.fillColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 0.6483304795)
            newLayer.strokeColor = #colorLiteral(red: 0.1896808545, green: 0.5544475485, blue: 0.8020701142, alpha: 1)
            newLayer.lineWidth = 3
            newLayer.lineCap = .round
            
            self.componentsToLayers[component] = layer
            self.layersToSublayers[layer] = newLayer
            
            let newView = UIView(frame: CGRect(x: component.x, y: component.y, width: component.width, height: component.height))
            self.view.insertSubview(newView, aboveSubview: self.sceneView)
            //print(newView.frame)
            
            let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
            strokeAnimation.fromValue = 0
            strokeAnimation.toValue = 1
            strokeAnimation.duration = 0.3
            strokeAnimation.autoreverses = false
            strokeAnimation.repeatCount = 0
            let x = newLayer.bounds.size.width / 2
            let y = newLayer.bounds.size.height / 2
            
            //newView.layer.position = CGPoint(x: component.x, y: component.y)
            newView.layer.addSublayer(layer)
            layer.addSublayer(newLayer)
            newLayer.position = CGPoint(x: x, y: y)
            newLayer.add(strokeAnimation, forKey: "line")

            component.baseView = newView
            component.changed = true //so don't delete from superview
            self.layerScaleAnimation(layer: newLayer, duration: 0.2, fromValue: 1.2, toValue: 1)
        }
    }
    func animateFoundFastChange() {
        for newComponent in nextComponents {
            var lowestDist = CGFloat(10000)
            var distToComp = [CGFloat: Component]()
            
            for oldComponent in currentComponents {
                if oldComponent.changed == false {
                    let currentCompPoint = CGPoint(x: oldComponent.x, y: oldComponent.y)
                    let nextCompPoint = CGPoint(x: newComponent.x, y: newComponent.y)
                    let distanceBetweenPoints = distance(currentCompPoint, nextCompPoint) //< 10
                    if distanceBetweenPoints <= lowestDist {
                        lowestDist = distanceBetweenPoints
                        distToComp[lowestDist] = oldComponent
                    }
                }
            }
            
            if lowestDist <= 50 {
                guard let oldComp = distToComp[lowestDist] else { return }
                let currentCompPoint = CGPoint(x: oldComp.x, y: oldComp.y)
                let nextCompPoint = CGPoint(x: newComponent.x, y: newComponent.y)
                
                let newView = oldComp.baseView
                DispatchQueue.main.async {
                    newView?.isHidden = false
                    newView?.alpha = 0
                    
                    oldComp.changed = true
                    newComponent.changed = true

                    UIView.animate(withDuration: 1, animations: {
                        newView?.alpha = 1
                        let xDist = nextCompPoint.x - currentCompPoint.x
                        let yDist = nextCompPoint.y - currentCompPoint.y
                        //print(newView)
                        print(xDist)
                        print(yDist)
                        print(newView?.frame)
                        newView?.frame.origin.x += xDist
                        newView?.frame.origin.y += yDist
                        print(newView?.frame)
                        print("ANIMATE")
                    })
                }
            } else {
                scaleInHighlight(component: newComponent)
                
                //newComponent.changed = false
            }
            
            
            
        }
        print(currentComponents.count)
//        for next in nextComponents {
//            //next.changed = false
//            currentComponents.append(next)
//            //next.changed = false
//        }
        for comp in currentComponents {
            if comp.changed == false {
                let theView = comp.baseView

                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.2, animations: {
                            theView?.alpha = 0
                        }, completion: { _ in
                            theView?.isHidden = true
                            theView?.removeFromSuperview()
                            self.currentComponents.remove(object: comp)
                            //self.componentsToViews.removeValue(forKey: comp)
                        })
                    }
                //comp.changed = true
            } else { ///    position has been changed
                comp.changed = false
            }
        }
//        currentComponents.removeAll()
     //   currentComponents += nextComponents
        print(currentComponents.count)
 
        for next in nextComponents {
            if next.changed == false {
                print("fal")
                currentComponents.append(next)
            }
        }
        print(currentComponents.count)
        nextComponents.removeAll()
        print("currentComponents.count: \(currentComponents.count)")
    
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
            let convertedOriginalWidthOfBigImage = self.aspectRatioWidthOverHeight * self.deviceSize.height
            let offsetWidth = convertedOriginalWidthOfBigImage - self.deviceSize.width
            let offHalf = offsetWidth / 2
            
            let newW = component.width * convertedOriginalWidthOfBigImage
            let newH = component.height * self.deviceSize.height
            let newX = component.x * convertedOriginalWidthOfBigImage - offHalf
            let newY = component.y * self.deviceSize.height
            //print("x: \(newX) y: \(newY) width: \(newW) height: \(newH)")
            let layer = CAShapeLayer()
            layer.frame = CGRect(x: newX, y: newY, width: newW, height: newH)
            layer.cornerRadius = newH / 3.5
            self.animateFastChange(layer: layer)
            
        
        }
    }
    func resetFastHighlights() {
        for highlight in currentComponents {
            componentsToLayers[highlight]?.removeFromSuperlayer()
        }
        for secondHighlight in nextComponents {
            componentsToLayers[secondHighlight]?.removeFromSuperlayer()
        }
    }
    func animateFastChange(layer: CAShapeLayer) {
            view.layer.insertSublayer(layer, above: sceneView.layer)
            layer.masksToBounds = true
            let gradient = CAGradientLayer()
            gradient.frame = layer.bounds
            gradient.colors = [#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor, #colorLiteral(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.4).cgColor, #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor]
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
