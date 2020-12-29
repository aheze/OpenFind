//
//  NewShutterButton.swift
//  Find
//
//  Created by Andrew on 1/12/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

class NewShutterButton: UIButton {
    
    
    var path: UIBezierPath!
    var createdCircle = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func draw(_ rect: CGRect) {
        self.createCircle()
        createdCircle = true
    }
    func createCircle() {
        if createdCircle == false {
            let borderWidth = CGFloat(6)
            
            let halfR = borderWidth / 2
            let width = self.frame.size.width
            let height = self.frame.size.height
            
            let path = UIBezierPath(ovalIn: CGRect(x: 0 + halfR, y: 0 + halfR, width: width - borderWidth, height: height - borderWidth))
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.lineWidth = borderWidth
            shapeLayer.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.15)
            shapeLayer.strokeColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            self.layer.addSublayer(shapeLayer)
        }
    }
    
}
