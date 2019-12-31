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
            print("no results")
            return
        }
        
        for result in results {
            //numberOfFastMatches = 0
            var foundAMatch = false
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
                        foundAMatch = true
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
    func scaleInHighlight(layer: CAShapeLayer, newLayer: CAShapeLayer) {
        let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeAnimation.fromValue = 0
        strokeAnimation.toValue = 1
        strokeAnimation.duration = 0.3
        strokeAnimation.autoreverses = false
        strokeAnimation.repeatCount = 0
        newLayer.add(strokeAnimation, forKey: "line")

        view.layer.insertSublayer(layer, above: sceneView.layer)
        layer.addSublayer(newLayer)
        layerScaleAnimation(layer: newLayer, duration: 0.2, fromValue: 1.2, toValue: 1)
    }
    func animateFoundFastChange() {
        for newComponent in nextComponents {
            //print("ans")
            let layer = CAShapeLayer()
            layer.frame = CGRect(x: newComponent.x, y: newComponent.y, width: newComponent.width, height: newComponent.height)
            layer.cornerRadius = newComponent.height / 3.5
            print(newComponent.x)
            let newLayer = CAShapeLayer()
            newLayer.bounds = layer.frame
            newLayer.path = UIBezierPath(roundedRect: layer.frame, cornerRadius: newComponent.height / 3.5).cgPath
            newLayer.fillColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 0.6483304795)
            newLayer.strokeColor = #colorLiteral(red: 0.1896808545, green: 0.5544475485, blue: 0.8020701142, alpha: 1)
            newLayer.lineWidth = 3
            newLayer.lineCap = .round
            
            var arrayOfDistances = [CGFloat]()
            var num = 0
            for oldComponent in currentComponents {
                print("old:")
                print(oldComponent.x)
                num += 1
                //print(num)
                let currentCompPoint = CGPoint(x: oldComponent.x, y: oldComponent.y)
                let nextCompPoint = CGPoint(x: newComponent.x, y: newComponent.y)
                let distanceBetweenPoints = distance(currentCompPoint, nextCompPoint) //< 10
                arrayOfDistances.append(distanceBetweenPoints)
                //print(distanceBetweenPoints)
            }
            if let minDist = arrayOfDistances.min() {
                //print(arrayOfDistances)
                //print(minDist)
                if let position = arrayOfDistances.firstIndex(of: minDist) {
                    if minDist <= 8 {
                        let oldComp = currentComponents[position]
                        let oldLayer = componentsToLayers[oldComp]
                        let moveAnimation = CABasicAnimation(keyPath: "position")

                        print(oldComp.x)
                        let currentCompPoint = CGPoint(x: oldComp.x, y: oldComp.y)
                        let nextCompPoint = CGPoint(x: newComponent.x, y: newComponent.y)
                        print(currentCompPoint)
                        print(nextCompPoint)
                        moveAnimation.fromValue = currentCompPoint            // animate from current position ...
                        moveAnimation.toValue = nextCompPoint                         // ... to wherever the new position is
                        moveAnimation.duration = 2
                        
//                        let newLayer = CAShapeLayer()
//                        lay
                        oldLayer?.position = nextCompPoint                       // set the shape's final position to be the new position so when the animation is done, it's at its new "home"
                        oldLayer?.add(moveAnimation, forKey: nil)
                        
                    } else {
                        print("no1")
                        scaleInHighlight(layer: layer, newLayer: newLayer)
                    }
                } else {
                    print("no2")
                    scaleInHighlight(layer: layer, newLayer: newLayer)
                }
            } else {
                print("no3")
                scaleInHighlight(layer: layer, newLayer: newLayer)
            }
            
            
            
        }
//        for newComponent in newComponents {
//
//        let convertedOriginalWidthOfBigImage = self.aspectRatioWidthOverHeight * self.deviceSize.height
//        let offsetWidth = convertedOriginalWidthOfBigImage - self.deviceSize.width
//        let offHalf = offsetWidth / 2
//
//        let newW = newComponent.width * convertedOriginalWidthOfBigImage
//        let newH = newComponent.height * self.deviceSize.height
//        let newX = newComponent.x * convertedOriginalWidthOfBigImage - offHalf
//        let newY = newComponent.y * self.deviceSize.height
//
//        let individualCharacterWidth = newW / CGFloat(newComponent.text.count)
//        //print(newComponent.text.count)
//        //print(individualCharacterWidth)
//        let indicies = newComponent.text.indicesOf(string: finalTextToFind)
//
//       // if numberOfFastMatches == 0 {
//            for index in indicies {
//                let addedWidth = individualCharacterWidth * CGFloat(index)
//                let finalX = newX + addedWidth
//                let finalW = individualCharacterWidth * CGFloat(finalTextToFind.count)
//                let layer = CAShapeLayer()
//                layer.frame = CGRect(x: finalX, y: newY, width: finalW, height: newH)
//                layer.cornerRadius = newH / 3.5
//                let newLayer = CAShapeLayer()
//                newLayer.bounds = layer.frame
//                newLayer.path = UIBezierPath(roundedRect: layer.frame, cornerRadius: newH / 3.5).cgPath
//                newLayer.fillColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 0.6483304795)
//                newLayer.strokeColor = #colorLiteral(red: 0.1896808545, green: 0.5544475485, blue: 0.8020701142, alpha: 1)
//                newLayer.lineWidth = 3
//                newLayer.lineCap = .round
//
//                if numberOfFastMatches == 0 {
//
//                    let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
//                    strokeAnimation.fromValue = 0
//                    strokeAnimation.toValue = 1
//                    strokeAnimation.duration = 0.3
//                    strokeAnimation.autoreverses = false
//                    strokeAnimation.repeatCount = 0
//                    newLayer.add(strokeAnimation, forKey: "line")
//
//                    view.layer.insertSublayer(layer, above: sceneView.layer)
//                    layer.addSublayer(newLayer)
//                    layerScaleAnimation(layer: newLayer, duration: 0.2, fromValue: 1.2, toValue: 1)
//                    //currentComponents = nextComponents
//
//                } else {
//                    for nextComp in nextComponents {
//                        print("sdgb")
//                        var arrayOfDistances = [CGFloat]()
//                        for comp in currentComponents {
//                            let currentCompPoint = CGPoint(x: comp.x, y: comp.y)
//                            let nextCompPoint = CGPoint(x: nextComp.x, y: nextComp.y)
//                            let distanceBetweenPoints = distance(currentCompPoint, nextCompPoint) //< 10 {
//                            arrayOfDistances.append(distanceBetweenPoints)
//                        }
//                        print(arrayOfDistances)
//                        guard let minDist = arrayOfDistances.min() else { return }
//                        guard let position = arrayOfDistances.firstIndex(of: minDist) else {return}
//                        if minDist <= 10 {
//
//                            let oldComp = currentComponents[position]
//                            let oldLayer = componentsToLayers[oldComp]
//                            let moveAnimation = CABasicAnimation(keyPath: "position")
//
//                            let currentCompPoint = CGPoint(x: oldComp.x, y: oldComp.y)
//                            let nextCompPoint = CGPoint(x: nextComp.x, y: nextComp.y)
//
//                            moveAnimation.fromValue = currentCompPoint            // animate from current position ...
//                            moveAnimation.toValue = nextCompPoint                         // ... to wherever the new position is
//                            moveAnimation.duration = 2
//
//                            oldLayer?.position = nextCompPoint                       // set the shape's final position to be the new position so when the animation is done, it's at its new "home"
//                            oldLayer?.add(moveAnimation, forKey: nil)
//                        }
//
//                        if currentComponents.count == 0 {
//
//                            let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
//                                               strokeAnimation.fromValue = 0
//                                               strokeAnimation.toValue = 1
//                                               strokeAnimation.duration = 0.3
//                                               strokeAnimation.autoreverses = false
//                                               strokeAnimation.repeatCount = 0
//                                               newLayer.add(strokeAnimation, forKey: "line")
//
//                                               view.layer.insertSublayer(layer, above: sceneView.layer)
//                                               layer.addSublayer(newLayer)
//                                               layerScaleAnimation(layer: newLayer, duration: 0.2, fromValue: 1.2, toValue: 1)
//                        }
//                    }
        currentComponents.removeAll()
//        for next in nextComponents {
//            print("nextX")
//            print(next.x)
//            currentComponents.append(next)
//        }
       
        currentComponents = nextComponents
         nextComponents.removeAll()
        print("_____________________________")
//
//                }
//            }
////        } else {
////
////
////        }
//
//    }
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
