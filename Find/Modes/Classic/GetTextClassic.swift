//
//  GetTextClassic.swift
//  Find
//
//  Created by Andrew on 10/15/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit
import ARKit

extension ViewController {
    func getTextClassic(stringToFind: String, component: Component, alternate: Bool) {
        let point = CGPoint(x: component.x, y: component.y)
        //print("point is \(point)")
        var newPoint = CGPoint()
        newPoint.x = deviceSize.width * point.x
        newPoint.y = deviceSize.height - (deviceSize.height * point.y)
        
        let realComponentWidth = component.width * deviceSize.width
        let realComponentHeight = component.height * deviceSize.height
        var individualCharacterWidth = realComponentWidth / CGFloat(component.text.count)
        //print("indc: \(individualCharacterWidth)")
    
        //print("NEWpoint is \(newPoint)")
        ///cgimage is 4/3, device size is 9/16
        if aspectRatioSucceeded == true {
//            let convertedPoint = CGPoint(x: component.x, y: component.y)
//            let deviceSizeWidthOverHeight = deviceSize.width / deviceSize.height
//            let offset = aspectRatioWidthOverHeight - deviceSizeWidthOverHeight
//            let halfOffset = offset / 2
//            let realWorldWidth = deviceSize.width
            
            print(deviceSize.height)
            print(deviceSize.width)
            print(aspectRatioWidthOverHeight)
            let convertedWidth = deviceSize.height * aspectRatioWidthOverHeight
            print(convertedWidth)
            if convertedWidth >= deviceSize.width {
                let offset = convertedWidth - deviceSize.width
                let halfOffset = offset / 2
                newPoint.x = convertedWidth * point.x
                newPoint.x -= halfOffset
                print(halfOffset)
                let newComponentWidth = component.width * convertedWidth
                let newIndividualCharacterWidth = newComponentWidth / CGFloat(component.text.count)
                individualCharacterWidth = newIndividualCharacterWidth
                
            }
            
        }
        
        let indicies = component.text.indicesOf(string: stringToFind)
        if indicies.count >= 0 {
            
            
            for index in indicies {
                //print("index: \(index)")
                let addedWidth = CGFloat(index) * individualCharacterWidth
                let finalPoint = CGPoint(x: newPoint.x + addedWidth, y: newPoint.y)
                
                let results = sceneView.hitTest(finalPoint, types: .existingPlaneUsingExtent)
                
                if let hitResult = results.first {
                    let realTextWidth = (individualCharacterWidth * CGFloat(stringToFind.count)) / CGFloat(2000)
                    
                    let highlight = SCNBox(width: realTextWidth, height: 0.001, length: realComponentHeight / 2000, chamferRadius: 0.001)
                    
//                    let sizeForHighlight = CGSize(width: realComponentWidth/2000, height: realComponentHeight/2000)
//                    let highlight = makeHighlightShape(size: sizeForHighlight)
                    let material = SCNMaterial()
                    let highlightColor : UIColor = #colorLiteral(red: 0, green: 0.7389578223, blue: 0.9509587884, alpha: 1)
                    material.diffuse.contents = highlightColor.withAlphaComponent(0.95)
                    highlight.materials = [material]
                    
                    let node = SCNNode(geometry: highlight)
                    node.transform = SCNMatrix4(hitResult.anchor!.transform)
                    node.position = SCNVector3(
                        
                        x: hitResult.worldTransform.columns.3.x,
                        y: hitResult.worldTransform.columns.3.y,
                        z: hitResult.worldTransform.columns.3.z
                    )
                    
                guard let anchoredNode =  sceneView.node(for: hitResult.anchor!) else { return }
                let anchorNodeOrientation = anchoredNode.worldOrientation
                    if anchorNodeOrientation.x == Float(0) && anchorNodeOrientation.z == Float(0) {
                    ///plane detected is horizontal
                    let billboardConstraint = SCNBillboardConstraint()
                    billboardConstraint.freeAxes = [.Y]
                    node.constraints = [billboardConstraint]
                }
                    //else {
                    ///is vertical
                    //let billboardConstraint = SCNBillboardConstraint()
                    //billboardConstraint.freeAxes = [.X]
                    //node.constraints = [billboardConstraint]
               // }
                    
                    classicHasFoundOne = true
                    sceneView.scene.rootNode.addChildNode(node)
                    amountOfMatches += 1
                    if matchesCanAcceptNewValue == true {
                        DispatchQueue.main.async {
                            self.numberLabel.text = "\(self.amountOfMatches)"
                        }
                    }
                    if alternate == true {
                        //print("normal---------")
                        classicHighlightArray.append(node)
                        let action = SCNAction.fadeOpacity(to: 0.8, duration: 0.3)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                node.runAction(action)
                            }
                        
                    } else {
                        //print("alternate-------")
                        secondClassicHighlightArray.append(node)
                        let action = SCNAction.fadeOpacity(to: 0.8, duration: 0.3)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                node.runAction(action)
                            }
                    }
                    fadeHighlights()
                }
            }
        }
        
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
