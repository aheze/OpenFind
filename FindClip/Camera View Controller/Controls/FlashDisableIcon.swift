//
//  FlashDisableIcon.swift
//  FindAppClip1
//
//  Created by Zheng on 3/13/21.
//

import UIKit

class FlashDisableIcon: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    var slashLayer: CAShapeLayer?
    
    func setup() {
        
        // Create a CAShapeLayer
        let slashLayer = CAShapeLayer()

        let slashPath = createBezierPath()
        
        // The Bezier path that we made needs to be converted to
        // a CGPath before it can be used on a layer.
        slashLayer.path = slashPath.cgPath
        
        slashLayer.fillColor = UIColor.clear.cgColor
        slashLayer.lineWidth = 3
        slashLayer.strokeColor = UIColor.white.withAlphaComponent(0.9).cgColor
        slashLayer.lineCap = .round
        slashLayer.lineJoin = .round
        slashLayer.strokeEnd = 0

        // add the new layer to our custom view
        self.layer.addSublayer(slashLayer)
        self.slashLayer = slashLayer
        
        alpha = 0
        
    }
    
    func animateSlash(lock: Bool) {
    
        if let slashLayer = slashLayer {
            if let currentValue = slashLayer.presentation()?.value(forKeyPath: #keyPath(CAShapeLayer.strokeEnd)) {
                let currentStrokeEnd = currentValue as! CGFloat
                slashLayer.strokeEnd = currentStrokeEnd
                slashLayer.removeAllAnimations()
            }
            
            let percentage: CGFloat = lock ? 1 : 0
            
            let animation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeEnd))
            animation.fromValue = slashLayer.strokeEnd
            animation.toValue = 1 * percentage
            animation.duration = 0.5
            slashLayer.strokeEnd = 1 * percentage
            slashLayer.add(animation, forKey: "lineAnimation")
        }
        
        UIView.animate(withDuration: 0.5) {
            self.alpha = lock ? 1 : 0
        }
    }
    func createBezierPath() -> UIBezierPath {
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 0, y: 16))
        bezierPath.addLine(to: CGPoint(x: 16, y: 0))
        
        return bezierPath
    }
}


