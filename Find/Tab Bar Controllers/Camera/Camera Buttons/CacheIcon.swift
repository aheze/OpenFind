//
//  CacheIcon.swift
//  FindTabBar
//
//  Created by Zheng on 12/28/20.
//

import UIKit

class CacheIcon: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    var rimLayer: CAShapeLayer?
    var inactiveCheckLayer: CAShapeLayer?
    var checkLayer: CAShapeLayer?
    
    func setup() {
        
        //// Color Declarations
        let fillColor = UIColor(named: "TabIconBackground-Dark")!
        let strokeColor = UIColor(named: "TabIconDetails-Dark")!
        let activeStrokeColor = UIColor(named: "100Blue")!

        // Create a CAShapeLayer
        let rimLayer = CAShapeLayer()
        let inactiveCheckLayer = CAShapeLayer()
        let checkLayer = CAShapeLayer()

        let (rimPath, checkPath) = createBezierPaths()
        // The Bezier path that we made needs to be converted to
        // a CGPath before it can be used on a layer.
        rimLayer.path = rimPath.cgPath
        inactiveCheckLayer.path = checkPath.cgPath
        checkLayer.path = checkPath.cgPath
        
        rimLayer.fillColor = fillColor.cgColor
        
        inactiveCheckLayer.fillColor = UIColor.clear.cgColor
        inactiveCheckLayer.lineWidth = 4
        inactiveCheckLayer.strokeColor = strokeColor.cgColor
        inactiveCheckLayer.lineCap = .round
        inactiveCheckLayer.lineJoin = .round
        checkLayer.fillColor = UIColor.clear.cgColor
        checkLayer.lineWidth = 4
        checkLayer.strokeColor = activeStrokeColor.cgColor
        checkLayer.lineCap = .round
        checkLayer.lineJoin = .round
        checkLayer.strokeEnd = 0

        // add the new layer to our custom view
        self.layer.addSublayer(rimLayer)
        self.layer.addSublayer(inactiveCheckLayer)
        self.layer.addSublayer(checkLayer)
        self.rimLayer = rimLayer
        self.inactiveCheckLayer = inactiveCheckLayer
        self.checkLayer = checkLayer
        
    }
    
    func animateCheck(percentage: CGFloat) {
        if let checkLayer = checkLayer {
            if let currentValue = checkLayer.presentation()?.value(forKeyPath: #keyPath(CAShapeLayer.strokeEnd)) {
                let currentStrokeEnd = currentValue as! CGFloat
                checkLayer.strokeEnd = currentStrokeEnd
                checkLayer.removeAllAnimations()
            }
            let animation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeEnd))
            animation.fromValue = checkLayer.strokeEnd
            animation.toValue = 1 * percentage
            animation.duration = Double(Constants.transitionDuration)
            checkLayer.strokeEnd = 1 * percentage
            checkLayer.add(animation, forKey: "lineAnimation")
        }
    }
    func toggleRim(light: Bool) {
        if let rimLayer = rimLayer {
            if let currentValue = rimLayer.presentation()?.value(forKeyPath: #keyPath(CAShapeLayer.fillColor)) {
                let currentFillColor = currentValue as! CGColor
                rimLayer.fillColor = currentFillColor
                rimLayer.removeAllAnimations()
            }
            
            let fillColor: CGColor
            if light {
                fillColor = UIColor(named: "TabIconDetails-Dark")!.cgColor
            } else {
                fillColor = UIColor(named: "TabIconBackground-Dark")!.cgColor
            }
            
            let animation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.fillColor))
            animation.fromValue = rimLayer.fillColor
            animation.toValue = fillColor
            animation.duration = Double(Constants.transitionDuration)
            rimLayer.fillColor = fillColor
            rimLayer.add(animation, forKey: "backgroundColor")
        }
    }

    func createBezierPaths() -> (UIBezierPath, UIBezierPath) {
        
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 16.23, y: 1))
        bezierPath.addCurve(to: CGPoint(x: 22.55, y: 2.16), controlPoint1: CGPoint(x: 19.21, y: 1), controlPoint2: CGPoint(x: 21, y: 1.4))
        bezierPath.addLine(to: CGPoint(x: 19.46, y: 6.57))
        bezierPath.addCurve(to: CGPoint(x: 15.86, y: 6), controlPoint1: CGPoint(x: 18.59, y: 6.2), controlPoint2: CGPoint(x: 17.56, y: 6))
        bezierPath.addLine(to: CGPoint(x: 14.14, y: 6))
        bezierPath.addCurve(to: CGPoint(x: 10.07, y: 6.8), controlPoint1: CGPoint(x: 12.13, y: 6), controlPoint2: CGPoint(x: 11.05, y: 6.28))
        bezierPath.addCurve(to: CGPoint(x: 7.8, y: 9.07), controlPoint1: CGPoint(x: 9.09, y: 7.32), controlPoint2: CGPoint(x: 8.32, y: 8.09))
        bezierPath.addCurve(to: CGPoint(x: 7, y: 12.81), controlPoint1: CGPoint(x: 7.31, y: 9.99), controlPoint2: CGPoint(x: 7.03, y: 11.01))
        bezierPath.addLine(to: CGPoint(x: 7, y: 13.14))
        bezierPath.addLine(to: CGPoint(x: 7, y: 16.86))
        bezierPath.addCurve(to: CGPoint(x: 7.8, y: 20.93), controlPoint1: CGPoint(x: 7, y: 18.87), controlPoint2: CGPoint(x: 7.28, y: 19.95))
        bezierPath.addCurve(to: CGPoint(x: 10.07, y: 23.2), controlPoint1: CGPoint(x: 8.32, y: 21.91), controlPoint2: CGPoint(x: 9.09, y: 22.68))
        bezierPath.addCurve(to: CGPoint(x: 13.81, y: 24), controlPoint1: CGPoint(x: 10.99, y: 23.69), controlPoint2: CGPoint(x: 12.01, y: 23.97))
        bezierPath.addLine(to: CGPoint(x: 14.14, y: 24))
        bezierPath.addLine(to: CGPoint(x: 15.86, y: 24))
        bezierPath.addCurve(to: CGPoint(x: 19.93, y: 23.2), controlPoint1: CGPoint(x: 17.87, y: 24), controlPoint2: CGPoint(x: 18.95, y: 23.72))
        bezierPath.addCurve(to: CGPoint(x: 22.2, y: 20.93), controlPoint1: CGPoint(x: 20.91, y: 22.68), controlPoint2: CGPoint(x: 21.68, y: 21.91))
        bezierPath.addCurve(to: CGPoint(x: 23, y: 17.19), controlPoint1: CGPoint(x: 22.69, y: 20.01), controlPoint2: CGPoint(x: 22.97, y: 18.99))
        bezierPath.addLine(to: CGPoint(x: 23, y: 16.86))
        bezierPath.addLine(to: CGPoint(x: 23, y: 15.46))
        bezierPath.addLine(to: CGPoint(x: 27.65, y: 8.82))
        bezierPath.addCurve(to: CGPoint(x: 28, y: 12.77), controlPoint1: CGPoint(x: 27.88, y: 9.89), controlPoint2: CGPoint(x: 28, y: 11.15))
        bezierPath.addLine(to: CGPoint(x: 28, y: 17.23))
        bezierPath.addCurve(to: CGPoint(x: 26.66, y: 23.88), controlPoint1: CGPoint(x: 28, y: 20.43), controlPoint2: CGPoint(x: 27.54, y: 22.25))
        bezierPath.addCurve(to: CGPoint(x: 22.88, y: 27.66), controlPoint1: CGPoint(x: 25.79, y: 25.51), controlPoint2: CGPoint(x: 24.51, y: 26.79))
        bezierPath.addCurve(to: CGPoint(x: 16.23, y: 29), controlPoint1: CGPoint(x: 21.25, y: 28.54), controlPoint2: CGPoint(x: 19.43, y: 29))
        bezierPath.addLine(to: CGPoint(x: 13.77, y: 29))
        bezierPath.addCurve(to: CGPoint(x: 7.12, y: 27.66), controlPoint1: CGPoint(x: 10.57, y: 29), controlPoint2: CGPoint(x: 8.75, y: 28.54))
        bezierPath.addCurve(to: CGPoint(x: 3.34, y: 23.88), controlPoint1: CGPoint(x: 5.49, y: 26.79), controlPoint2: CGPoint(x: 4.21, y: 25.51))
        bezierPath.addCurve(to: CGPoint(x: 2, y: 17.23), controlPoint1: CGPoint(x: 2.46, y: 22.25), controlPoint2: CGPoint(x: 2, y: 20.43))
        bezierPath.addLine(to: CGPoint(x: 2, y: 12.77))
        bezierPath.addCurve(to: CGPoint(x: 3.34, y: 6.12), controlPoint1: CGPoint(x: 2, y: 9.57), controlPoint2: CGPoint(x: 2.46, y: 7.75))
        bezierPath.addCurve(to: CGPoint(x: 7.12, y: 2.34), controlPoint1: CGPoint(x: 4.21, y: 4.49), controlPoint2: CGPoint(x: 5.49, y: 3.21))
        bezierPath.addCurve(to: CGPoint(x: 13.77, y: 1), controlPoint1: CGPoint(x: 8.75, y: 1.46), controlPoint2: CGPoint(x: 10.57, y: 1))
        bezierPath.addLine(to: CGPoint(x: 16.23, y: 1))
        bezierPath.close()
        bezierPath.usesEvenOddFillRule = true
        
        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 10.58, y: 14.33))
        bezier2Path.addLine(to: CGPoint(x: 15.2, y: 19.69))
        bezier2Path.addLine(to: CGPoint(x: 24.79, y: 5.82))
        
        return (bezierPath, bezier2Path)
    }
}

