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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func draw(_ rect: CGRect) {
        self.createCircle()
    }
    func createCircle() {
        //print("frame: \(self.frame)")
        
        let borderWidth = CGFloat(6)
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
        shapeLayer.fillColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        shapeLayer.strokeColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.layer.addSublayer(shapeLayer)
    }
    
}
