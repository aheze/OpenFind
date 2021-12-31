//
//  Utilities+CGRect.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/30/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//
    

import UIKit

extension CGRect {
    var center: CGPoint {
        CGPoint(x: self.midX, y: self.midY)
    }
    
    
    func scaleTo(_ size: CGSize) -> CGRect {
        var rect = CGRect(
            x: self.origin.x * size.width,
            y: self.origin.y * size.height,
            width: self.width * size.width,
            height: self.height * size.height
        )
        rect = rect.insetBy(dx: -3, dy: -3)
        
        return rect
    }
}
