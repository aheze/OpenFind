//
//  HighlightShape.swift
//  Find
//
//  Created by Andrew on 10/17/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import Foundation
import ARKit

extension ViewController {
    
    func makeHighlightShape(size: CGSize) -> SCNShape {
        
        
        let rectWidth: CGFloat = size.width
        let rectHeight: CGFloat = size.height
        let rectCornerRadius = rectHeight / 4.5
        
        let point = CGPoint(x: 0 - (rectWidth / 2), y: rectHeight / 2)
        let rect = CGRect(origin: point, size: CGSize(width: rectWidth, height: rectHeight))
        
        let path = UIBezierPath(roundedRect: rect, cornerRadius: rectCornerRadius)
        let shape = SCNShape(path: path, extrusionDepth: 0.002)
        let color = #colorLiteral(red: 0, green: 0.7389578223, blue: 0.9509587884, alpha: 1)
        shape.firstMaterial?.diffuse.contents = color
  
        return shape
        
    }
    
}
