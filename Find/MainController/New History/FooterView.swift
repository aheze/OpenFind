//
//  FooterView.swift
//  Find
//
//  Created by Andrew on 11/27/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

class FooterView: UICollectionReusableView {

    var path: UIBezierPath!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func draw(_ rect: CGRect) {
        self.createRectangle()
    }
    func createRectangle() {
        print("frame: \(self.frame)")
        
        let arcRadius = CGFloat(10)
        let width = self.frame.size.width
        print(self.frame.size.height)
        //let height = self.frame.size.height + arcRadius
        let height = CGFloat(self.frame.size.height)
        let origin = CGPoint(x: 0, y: -arcRadius)
        print(origin)
        
        // Initialize the path.
        path = UIBezierPath()
     
        // Specify the point that the path should start get drawn.
        path.move(to: origin)
        
        //first arc
        path.addArc(withCenter: CGPoint(x: arcRadius, y: -arcRadius), radius: arcRadius, startAngle: CGFloat(180).toRadians(), endAngle: CGFloat(90).toRadians(), clockwise: false)
     
        // Create a line between the end of the first arc and the start of the second
        path.addLine(to: CGPoint(x: width - arcRadius, y: 0))
        path.addArc(withCenter: CGPoint(x: width - arcRadius, y: -arcRadius), radius: arcRadius, startAngle: CGFloat(90).toRadians(), endAngle: CGFloat(0).toRadians(), clockwise: false)
     
        // Line from topmost right to bottom right
        path.addLine(to: CGPoint(x: width, y: height))
     
        // Line from bottom right to bottom left
        path.addLine(to: CGPoint(x: 0, y: height))
     
        // Close the path.
        path.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.white.cgColor
        self.layer.addSublayer(shapeLayer)
    }
    
}
extension CGFloat {
    func toRadians() -> CGFloat {
        return self * .pi / 180.0
    }
}
