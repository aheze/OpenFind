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

extension ViewController {
    
    func handleFastDetectedText(request: VNRequest?, error: Error?) {
        numberCurrentFastmodePass += 1
        guard let results = request?.results, results.count > 0 else {
            //print("no results")
            busyFastFinding = false
            return
        }
        
        for result in results {
            if let observation = result as? VNRecognizedTextObservation {
                for text in observation.topCandidates(1) {
                    //print(text.string)
                    let component = Component()
                    component.x = observation.boundingBox.origin.x
                    component.y = 1 - observation.boundingBox.minY
                    component.height = observation.boundingBox.height
                    component.width = observation.boundingBox.width
                    component.text = text.string
                    drawFastHighlight(component: component)
                    let lowerCaseFinalText = finalTextToFind.lowercased()
                    let lowerCaseComponentText = component.text.lowercased()
                
                    //print(lowerCaseFinalText)
                    //print(lowerCaseComponentText)
                    component.text = lowerCaseComponentText
                    
                
                    if lowerCaseComponentText.contains(lowerCaseFinalText) {
                        //print("sghiruiguhweiugsiugr+++++++++++")
                    //if component.text.contains(finalTextToFind) {
                        let convertedOriginalWidthOfBigImage = self.aspectRatioWidthOverHeight * self.deviceSize.height
                        let offsetWidth = convertedOriginalWidthOfBigImage - self.deviceSize.width
                        let offHalf = offsetWidth / 2
                        let newW = component.width * convertedOriginalWidthOfBigImage
                        let newH = component.height * self.deviceSize.height
                        let newX = component.x * convertedOriginalWidthOfBigImage - offHalf
                        let newY = component.y * self.deviceSize.height
                        let individualCharacterWidth = newW / CGFloat(component.text.count)
                        let finalW = individualCharacterWidth * CGFloat(finalTextToFind.count)
                        
                        let indicies = component.text.indicesOf(string: lowerCaseFinalText)
                        for index in indicies {
                            let addedWidth = individualCharacterWidth * CGFloat(index)
                            let finalX = newX + addedWidth
                            let newComponent = Component()
                            
                            newComponent.x = finalX - 4
                            newComponent.y = newY - (newH + 1)
                            newComponent.width = finalW + 8
                            newComponent.height = newH + 2
                            newComponent.text = "This value is not needed"
                            newComponent.changed = false
                            nextComponents.append(newComponent)
                            
                        }
                    }
                
                }
            }
            
        }
        busyFastFinding = false
        animateFoundFastChange()
        numberOfFastMatches = 0
    }
    
    
    
    
    func animateFoundFastChange() {
        //print("FastFound+++++++++++___________________________________++++++++++++++++++++++++++")
        
        
        for newComponent in nextComponents {
            //print("next looping")
            
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
            if shouldScale == true {
                if lowestDist <= 15 {
                    guard let oldComp = distToComp[lowestDist] else { print("NO COMP"); return }
                    let currentCompPoint = CGPoint(x: oldComp.x, y: oldComp.y)
                    let nextCompPoint = CGPoint(x: newComponent.x, y: newComponent.y)
                    
                    let newView = oldComp.baseView
                    let nextView = newComponent.baseView
                    tempComponents.append(oldComp)
                    oldComp.changed = true
                    //nextComponents.remove(object: newComponent)
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.5, animations: {
                            
                            let xDist = nextCompPoint.x - currentCompPoint.x
                            let yDist = nextCompPoint.y - currentCompPoint.y
                            let rect = CGRect(x: newComponent.x, y: newComponent.y, width: newComponent.width, height: newComponent.height)
                            newView?.frame = rect
                            
                            
                            //print("ANIMATE")
                        })
                    }
                } else {
                    scaleInHighlight(component: newComponent)
                }
            } else {
                guard let oldComp = distToComp[lowestDist] else { print("NO COMP"); return }
                let currentCompPoint = CGPoint(x: oldComp.x, y: oldComp.y)
                let nextCompPoint = CGPoint(x: newComponent.x, y: newComponent.y)
                let newView = oldComp.baseView
                let nextView = newComponent.baseView
                tempComponents.append(oldComp)
                oldComp.changed = true
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.5, animations: {                        let xDist = nextCompPoint.x - currentCompPoint.x
                        let yDist = nextCompPoint.y - currentCompPoint.y
                        let rect = CGRect(x: newComponent.x, y: newComponent.y, width: newComponent.width, height: newComponent.height)
                        newView?.frame = rect
                        print("ANIMATE, Matches Mode")
                    })
                }
            }
            
        }
        
        //print("Current: \(currentComponents.count)")
 
        for comp in currentComponents {
            if !tempComponents.contains(comp) {
                let theView = comp.baseView
                //print("remove comp because didn't change")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.2, animations: {
                            theView?.alpha = 0
                        }, completion: { _ in
                            theView?.isHidden = true
                            theView?.removeFromSuperview()
                            //self.currentComponents.remove(object: comp)
                        })
                    }
                })
            }
            
        }
        currentComponents.removeAll()
        currentComponents = tempComponents
        
        //print("next: \(nextComponents.count)")
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
        
        //print("Curr \(currentComponents.count)")
        for curr in currentComponents {
            curr.changed = false
        }
        //print("temp: \(tempComponents.count)")
        nextComponents.removeAll()
        tempComponents.removeAll()
        //print("currentComponents.count: \(currentComponents.count)")
        
        //print("END_______________________________________________________")
    
    }
    
    
    func scaleInHighlight(component: Component) {
        //print("scale")
        DispatchQueue.main.async {
            
            let layer = CAShapeLayer()
            layer.frame = CGRect(x: 0, y: 0, width: component.width, height: component.height)
            layer.cornerRadius = component.height / 3.5
            
            let newLayer = CAShapeLayer()
            newLayer.bounds = layer.frame
            newLayer.path = UIBezierPath(roundedRect: layer.frame, cornerRadius: component.height / 3.5).cgPath
            newLayer.fillColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 0.3030554367)
            newLayer.strokeColor = #colorLiteral(red: 0.1896808545, green: 0.5544475485, blue: 0.8020701142, alpha: 1)
            newLayer.lineWidth = 3
            newLayer.lineCap = .round
            
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
            component.changed = true
            
            self.layerScaleAnimation(layer: newLayer, duration: 0.2, fromValue: 1.2, toValue: 1)
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
            let convertedOriginalWidthOfBigImage = self.aspectRatioWidthOverHeight * self.deviceSize.height
            let offsetWidth = convertedOriginalWidthOfBigImage - self.deviceSize.width
            let offHalf = offsetWidth / 2
            
            let newW = component.width * convertedOriginalWidthOfBigImage
            let newH = component.height * self.deviceSize.height
            let newX = component.x * convertedOriginalWidthOfBigImage - offHalf
            let newY = component.y * self.deviceSize.height
            let buffer = CGFloat(3)
            let doubBuffer = CGFloat(6)
            //print("x: \(newX) y: \(newY) width: \(newW) height: \(newH)")
            let layer = CAShapeLayer()
            layer.frame = CGRect(x: newX - buffer, y: newY, width: newW + doubBuffer, height: newH)
            layer.cornerRadius = newH / 3.5
            self.animateFastChange(layer: layer)
            
        
        }
    }
    func resetFastHighlights() {
        DispatchQueue.main.async {
            for highlight in self.currentComponents {
                UIView.animate(withDuration: 0.5, delay: 0.8, animations: {
                    highlight.baseView?.alpha = 0
                }, completion: {
                    _ in highlight.baseView?.removeFromSuperview()
                    self.currentComponents.remove(object: highlight)
                })
            }
            for secondHighlight in self.nextComponents {
                UIView.animate(withDuration: 0.5, delay: 0.8, animations: {
                    secondHighlight.baseView?.alpha = 0
                }, completion: {
                    _ in secondHighlight.baseView?.removeFromSuperview()
                    self.nextComponents.remove(object: secondHighlight)
                })
            }
            for currentHighlight in self.currentComponents {
                UIView.animate(withDuration: 0.5, delay: 0.8, animations: {
                    currentHighlight.baseView?.alpha = 0
                }, completion: {
                    _ in currentHighlight.baseView?.removeFromSuperview()
                    self.tempComponents.remove(object: currentHighlight)
                })
            }
        }
    }
    func animateFastChange(layer: CAShapeLayer) {
            view.layer.insertSublayer(layer, above: sceneView.layer)
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

//extension ViewController {
//
//    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
//        print("up")
//    }
//    func renderer(_ renderer: SCNSceneRenderer, willUpdate node: SCNNode, for anchor: ARAnchor) {
//        print("sdk")
//    }
//
//
//}
