//
//  RippleEffect.swift
//  Find
//
//  Created by Andrew on 9/2/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

public extension UIView {
    
    public func rippleBorder(location: CGPoint, color: UIColor) {
        rippleBorder(location, color: color){}
    }
    
    public func rippleBorder(_ location: CGPoint, color: UIColor, then: @escaping ()->() ) {
        RippleEffect.border(self, locationInView: location, color: color, then: then)
    }
    
    public func rippleFill(_ location: CGPoint, color: UIColor) {
        rippleFill(location, color: color){}
    }
    
    public func rippleFill(_ location:CGPoint, color:UIColor, then: @escaping ()->() ) {
        RippleEffect.fill(self, locationInView: location, color: color, then: then)
    }
    
    public func rippleStop() {
        RippleEffect.stop(self)
    }
    
}

public class RippleEffect {
    
    private static var targetLayer: CALayer?
    
    public struct Option {
        public var borderWidth = CGFloat(5.0)
        public var radius = CGFloat(30.0)
        public var duration = CFTimeInterval(0.4)
        public var borderColor = UIColor.white
        public var fillColor = UIColor.clear
        public var scale = CGFloat(3.0)
        public var isRunSuperView = true
    }
    
    public class func option () -> Option {
        return Option()
    }
    
    public class func run(_ view:UIView, locationInView:CGPoint, option:RippleEffect.Option) {
        run(view, locationInView: locationInView, option: option){}
    }
    
    public class func run(_ view:UIView, locationInView:CGPoint, option:RippleEffect.Option, then: @escaping ()->() ) {
        prePreform(view, point: locationInView, option: option, isLocationInView: true, then: then)
    }
    
    public class func run(_ view:UIView, absolutePosition:CGPoint, option:RippleEffect.Option) {
        run(view, absolutePosition: absolutePosition, option: option){}
    }
    
    public class func run(_ view:UIView, absolutePosition:CGPoint, option:RippleEffect.Option, then: @escaping ()->() ) {
        prePreform(view, point: absolutePosition, option: option, isLocationInView: false, then: then)
    }
    
    public class func border(_ view:UIView, locationInView:CGPoint, color:UIColor) {
        border(view, locationInView: locationInView, color: color){}
    }
    
    public class func border(_ view:UIView, locationInView:CGPoint, color:UIColor, then: @escaping ()->() ) {
        var opt = RippleEffect.Option()
        opt.borderColor = color
        prePreform(view, point: locationInView, option: opt, isLocationInView: true, then: then)
    }
    
    public class func border(_ view:UIView, absolutePosition:CGPoint, color:UIColor) {
        border(view, absolutePosition: absolutePosition, color: color){}
    }
    
    public class func border(_ view:UIView, absolutePosition:CGPoint, color:UIColor, then: @escaping ()->() ) {
        var opt = RippleEffect.Option()
        opt.borderColor = color
        prePreform(view, point: absolutePosition, option: opt, isLocationInView: false, then: then)
    }
    
    public class func fill(_ view:UIView, locationInView:CGPoint, color:UIColor) {
        fill(view, locationInView: locationInView, color: color){}
    }
    
    public class func fill(_ view:UIView, locationInView:CGPoint, color:UIColor, then: @escaping ()->() ) {
        var opt = RippleEffect.Option()
        opt.borderColor = color
        opt.fillColor = color
        prePreform(view, point: locationInView, option: opt, isLocationInView: true, then: then)
    }
    
    public class func fill(_ view:UIView, absolutePosition:CGPoint, color:UIColor) {
        fill(view, absolutePosition: absolutePosition, color: color){}
    }
    
    public class func fill(_ view:UIView, absolutePosition:CGPoint, color:UIColor, then: @escaping ()->() ) {
        var opt = RippleEffect.Option()
        opt.borderColor = color
        opt.fillColor = color
        prePreform(view, point: absolutePosition, option: opt, isLocationInView: false, then: then)
    }
    
    private class func prePreform(_ view: UIView, point: CGPoint, option: RippleEffect.Option, isLocationInView: Bool, then: @escaping ()->() ) {
        
        let p = isLocationInView ? CGPoint(x: point.x + view.frame.origin.x, y: point.y + view.frame.origin.y) : point
        
        if option.isRunSuperView, let superview = view.superview {
            prePreform(
                superview,
                point: p,
                option: option,
                isLocationInView: isLocationInView,
                then: then
            )
        } else {
            perform(
                view,
                point:p,
                option:option,
                then: then
            )
        }
    }
    
    private class func perform(_ view:UIView, point:CGPoint, option: RippleEffect.Option, then: @escaping ()->() ) {
        UIGraphicsBeginImageContextWithOptions (
            CGSize(width: (option.radius + option.borderWidth) * 2, height: (option.radius + option.borderWidth) * 2), false, 3.0)
        let path = UIBezierPath(
            roundedRect: CGRect(x: option.borderWidth, y: option.borderWidth, width: option.radius * 2, height: option.radius * 2),
            cornerRadius: option.radius)
        option.fillColor.setFill()
        path.fill()
        option.borderColor.setStroke()
        path.lineWidth = option.borderWidth
        path.stroke()
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let opacity = CABasicAnimation(keyPath: "opacity")
        opacity.autoreverses = false
        opacity.fillMode = CAMediaTimingFillMode.forwards
        opacity.isRemovedOnCompletion = false
        opacity.duration = option.duration
        opacity.fromValue = 1.0
        opacity.toValue = 0.0
        
        let transform = CABasicAnimation(keyPath: "transform")
        transform.autoreverses = false
        transform.fillMode = CAMediaTimingFillMode.forwards
        transform.isRemovedOnCompletion = false
        transform.duration = option.duration
        transform.fromValue = NSValue(caTransform3D: CATransform3DMakeScale(1.0 / option.scale, 1.0 / option.scale, 1.0))
        transform.toValue = NSValue(caTransform3D: CATransform3DMakeScale(option.scale, option.scale, 1.0))
        
        var rippleLayer:CALayer? = targetLayer
        
        if rippleLayer == nil {
            rippleLayer = CALayer()
            view.layer.addSublayer(rippleLayer!)
            targetLayer = rippleLayer
            targetLayer?.addSublayer(CALayer())//Temporary, CALayer.sublayers is Implicitly Unwrapped Optional
        }
        
        DispatchQueue.main.async { [weak rippleLayer] in
            
            if let target = rippleLayer {
                let layer = CALayer()
                layer.contents = img?.cgImage
                layer.frame = CGRect(x: point.x - option.radius, y: point.y - option.radius, width: option.radius * 2, height: option.radius * 2)
                target.addSublayer(layer)
                CATransaction.begin()
                CATransaction.setAnimationDuration(option.duration)
                CATransaction.setCompletionBlock {
                    layer.contents = nil
                    layer.removeAllAnimations()
                    layer.removeFromSuperlayer()
                    then()
                }
                layer.add(opacity, forKey:nil)
                layer.add(transform, forKey:nil)
                CATransaction.commit()
            }
        }
    }
    
    public class func stop(_ view:UIView) {
        
        guard let sublayers = targetLayer?.sublayers else {
            return
        }
        
        for layer in sublayers {
            layer.removeAllAnimations()
        }
    }
    
}
