//
//  StatusView.swift
//  Find
//
//  Created by Andrew on 1/11/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

class StatusView: UIView, ChangeStatusValue {
    
    var createdCircle = false
    
    var number = 0
    
    var topRimLayer = CAShapeLayer()
    var previousValue = CGFloat(0.5)
    var startLineValue = CGFloat(0)
    public let Style = DefaultStyle.self
    var path: UIBezierPath!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    private let notificationCenter = NotificationCenter.default
    
    override func draw(_ rect: CGRect) {
     
        createCircle()
        createdCircle = true
    }
    func createCircle() {
        if createdCircle == false {
            print("CREATECIr")
            //print("frame: \(self.frame)")
            
            let borderWidth = CGFloat(6.5)
            //let arcRadius = CGFloat(3)
            
            
            let halfR = borderWidth / 2
            let width = self.frame.size.width
            //print(self.frame.size.height)
            //let height = self.frame.size.height + arcRadius
            let height = self.frame.size.height
            
            let path = UIBezierPath(ovalIn: CGRect(x: 0 + halfR, y: 0 + halfR, width: width - borderWidth, height: height - borderWidth))
            //path.lineWidth = borderWidth
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            //shapeLayer.frame = self.frame
            shapeLayer.lineWidth = borderWidth
            shapeLayer.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.15)
            shapeLayer.strokeColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            //shapeLayer.name = "shape"
            
            
            var topRimLayer = CAShapeLayer()
            topRimLayer.path = path.cgPath
            topRimLayer.lineWidth = borderWidth
            topRimLayer.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            topRimLayer.strokeColor = #colorLiteral(red: 0.8000000119, green: 0.8000000119, blue: 0.8000000119, alpha: 1)
            topRimLayer.lineCap = .round
            topRimLayer.name = "shape"
            
            var newFrameRect = CGRect(x: 0, y: 0, width: 0, height: 0)
            newFrameRect.size.width = path.bounds.size.width
            newFrameRect.size.height = path.bounds.size.height
            newFrameRect.origin.x = path.bounds.minX - halfR
            newFrameRect.origin.y = path.bounds.minY - halfR
    //        newFrameRect.size.x -= halfR
    //        newFrameRect.size.y -= halfR
            topRimLayer.frame = newFrameRect
          //  topRimLayer.position = layer.bounds.width - topRimLayer.bounds.width / 2
            
            let endAnimation = CABasicAnimation(keyPath: "strokeEnd")
            endAnimation.fromValue = 0.0
            endAnimation.toValue = 0.5
            endAnimation.duration = 1
            endAnimation.autoreverses = false
            endAnimation.repeatCount = 0
            endAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            topRimLayer.strokeEnd = 0.5
    //            let animation = CAAnimationGroup()
    //            animation.animations = [startAnimation, endAnimation]
    //            animation.duration = 0.6
    //            animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            
            topRimLayer.add(endAnimation, forKey: "EndAnimation")
            self.layer.insertSublayer(shapeLayer, at: 0)
            self.layer.insertSublayer(topRimLayer, above: shapeLayer)
        }
    }
    
    func changeValue(to value: CGFloat) {
        topRimLayer.removeAllAnimations()
//         number += 1
//        if number % 10 == 0 {
            //print("skjdfgsjkfghksjghdjkf")
            topRimLayer.strokeEnd = previousValue
            let endAnimation = CABasicAnimation(keyPath: "strokeEnd")
            endAnimation.fromValue = previousValue
            endAnimation.toValue = value
            endAnimation.duration = 0.1
            endAnimation.autoreverses = false
            endAnimation.repeatCount = 0
            
            topRimLayer.add(endAnimation, forKey: "newEnd")
            topRimLayer.strokeEnd = value
//        }
//        var newValue = value
//        if value == 1 {
//            print("onee")
//            newValue = 0.8
//        }
        
        previousValue = value
        //endAnimation.fillMode = .forwards
        
    }
//    func changeValue(to value: CGFloat) {
//        //print("change")
////        topRimLayer.
////        let shapeLayer = CAShapeLayer()
////        shapeLayer.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
////        shapeLayer.strokeColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1).cgColor
////        shapeLayer.lineWidth = 5
////        shapeLayer.path = path.cgPath
//
//        //topRimLayer.strokeStart = 0.05
//
//        var newValue = value
//        if value == 1 {
//            newValue = 0.99
//        }
//        if newValue < previousValue {
//
////            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
////            rotationAnimation.fromValue = 0.0
////            rotationAnimation.toValue = Float.pi * 2.0
////            rotationAnimation.duration = 0.4
////            rotationAnimation.repeatCount = 0
//
//            let endAnimation = CABasicAnimation(keyPath: "strokeEnd")
//            endAnimation.fromValue = previousValue
//            print("stroke: \(topRimLayer.presentation()?.strokeEnd)")
//            endAnimation.toValue = 0.9
//            endAnimation.duration = 0.4
//endAnimation.fillMode = .backwards
////endAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
////            let animation = CAAnimationGroup()
////            animation.animations = [rotationAnimation, endAnimation]
////            animation.duration = 0.4
////            animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
//            topRimLayer.removeAnimation(forKey: "EndAnimation")
//            topRimLayer.add(endAnimation, forKey: "EndAnimation")
//        } else if value > previousValue {
////            print("larger")
//////            let startAnimation = CABasicAnimation(keyPath: "strokeStart")
//////            startAnimation.fromValue = startLineValue
//////            startAnimation.toValue = startLineValue
////
////            let endAnimation = CABasicAnimation(keyPath: "strokeEnd")
////            endAnimation.fromValue = previousValue
////            endAnimation.toValue = value
////            endAnimation.duration = 0.1
////            //endAnimation.fillMode = .forwards
////            //endAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
////let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
////            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
////            rotationAnimation.fromValue = 0.0
////            rotationAnimation.toValue = Float.pi * 2.0
////            rotationAnimation.duration = 0.4
////            rotationAnimation.repeatCount = 0
////
////            let endAnimation = CABasicAnimation(keyPath: "strokeEnd")
////            endAnimation.fromValue = previousValue
////            endAnimation.toValue = value
////            endAnimation.duration = 0.4
//////endAnimation.fillMode = .forwards
//////endAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
////            let animation = CAAnimationGroup()
////            animation.animations = [rotationAnimation, endAnimation]
////            animation.duration = 0.4
////            animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
////            topRimLayer.add(endAnimation, forKey: "EndAnimation")
//            let endAnimation = CABasicAnimation(keyPath: "strokeEnd")
//            endAnimation.fromValue = previousValue
//            endAnimation.toValue = 0.5
//            endAnimation.duration = 0.1
//                    endAnimation.fillMode = .forwards
//                    //endAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
//
//
//            //            let animation = CAAnimationGroup()
//            //            animation.animations = [startAnimation, endAnimation]
//            //            animation.duration = 0.6
//            //            animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
//            topRimLayer.removeAnimation(forKey: "EndAnimation")
//            topRimLayer.add(endAnimation, forKey: "EndAnimation")
//        }
////        let startAnimation = CABasicAnimation(keyPath: "strokeStart")
//////            startAnimation.fromValue = startLineValue
//////            startAnimation.toValue = startLineValue
////
////        let endAnimation = CABasicAnimation(keyPath: "strokeEnd")
////        endAnimation.fromValue = previousValue
////        endAnimation.toValue = value
////        endAnimation.duration = 0.1
////        //endAnimation.fillMode = .
////        //endAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
////
////
//////            let animation = CAAnimationGroup()
//////            animation.animations = [startAnimation, endAnimation]
//////            animation.duration = 0.6
//////            animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
////        topRimLayer.add(endAnimation, forKey: "EndAnimation")
//        previousValue = value
//    }
    
}
