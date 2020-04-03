//
//  StatusView.swift
//  Find
//
//  Created by Andrew on 1/11/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

class StatusView: UIView {
    
    var createdCircle = false
    var number = 0
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
            let borderWidth = CGFloat(6.5)
            let halfR = borderWidth / 2
            let width = self.frame.size.width
            let height = self.frame.size.height
            
            let path = UIBezierPath(ovalIn: CGRect(x: 0 + halfR, y: 0 + halfR, width: width - borderWidth, height: height - borderWidth))
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.lineWidth = borderWidth
            shapeLayer.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.15)
            shapeLayer.strokeColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            
            var newFrameRect = CGRect(x: 0, y: 0, width: 0, height: 0)
            newFrameRect.size.width = path.bounds.size.width
            newFrameRect.size.height = path.bounds.size.height
            newFrameRect.origin.x = path.bounds.minX - halfR
            newFrameRect.origin.y = path.bounds.minY - halfR
            self.layer.insertSublayer(shapeLayer, at: 0)
        }
    }
}
