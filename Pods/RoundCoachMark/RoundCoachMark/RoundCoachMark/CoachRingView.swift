//
//  CoachRingView.swift
//  RoundCoachMark
//
//  Created by Dima Choock on 14/12/2017.
//  Copyright © 2017 GPB DIDZHITAL. All rights reserved.
//

import UIKit

class CoachRingView: UIView, CAAnimationDelegate
{
// MARK: - CONTROL INTERFACE
    
    public func openRing(_ open:Bool, completion:@escaping ()->Void)
    {
        completionBlock = completion
        
        animateRing(open)
        animateAperture(open)
        animateEcho(open)
    }
    
// MARK - ANIMATION ROUTINES
    
    private func animateRing(_ open:Bool)
    {
        guard let ring = ringGeometry else {return}
        let timing: CAMediaTimingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeInEaseOut)
        let end_radius = open ? ring.radius : ring.controlRadius
        let beg_radius = open ? ring.controlRadius : ring.radius
        
        let opening = CABasicAnimation(keyPath: "ringRadius")
        opening.duration = ringPeriod
        opening.fillMode = CAMediaTimingFillMode.both
        opening.timingFunction = timing
        opening.fromValue = beg_radius
        opening.toValue = end_radius
        opening.delegate = self
        layer.add(opening, forKey:"ring")
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        (layer as! CMRingLayer).ringRadius = end_radius
        CATransaction.commit()
    }
    private func animateAperture(_ open:Bool)
    {
        guard let ring = ringGeometry else {return}
        let timing: CAMediaTimingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        guard open
        else
        {
            layer.removeAnimation(forKey:"apertureRadius")
            (layer as! CMRingLayer).aperture = ring.controlRadius
            return
        }
        
        let pulse = CABasicAnimation(keyPath: "aperture")
        pulse.duration = aperturePeriod
        pulse.autoreverses = true
        pulse.repeatCount = Float.infinity
        pulse.fillMode = CAMediaTimingFillMode.both
        pulse.timingFunction = timing
        pulse.fromValue = ring.controlRadius
        pulse.toValue = ring.controlRadius + apertureTravel
        layer.add(pulse, forKey:"apertureRadius")
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        (layer as! CMRingLayer).aperture = ring.controlRadius + apertureTravel
        CATransaction.commit()
    }
    private func animateEcho(_ open:Bool)
    {
        guard let ring = ringGeometry else {return}
        let echo_timing: CAMediaTimingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.default)
        let opacity_timing: CAMediaTimingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.linear)
        let duration = aperturePeriod*2
        
        guard open
        else
        {
            layer.removeAnimation(forKey:"echoRadius")
            layer.removeAnimation(forKey:"echoOpacity")
            return
        }
        
        let pulse = CABasicAnimation(keyPath: "echo")
        pulse.duration = duration
        pulse.repeatCount = Float.infinity
        pulse.fillMode = CAMediaTimingFillMode.removed
        pulse.timingFunction = echo_timing
        pulse.fromValue = ring.controlRadius
        pulse.toValue = ring.controlRadius + echoTravel
        layer.add(pulse, forKey:"echoRadius")
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        (layer as! CMRingLayer).aperture = ring.controlRadius + echoTravel 
        CATransaction.commit()
        
        let opacity = CABasicAnimation(keyPath: "echoOpacity")
        opacity.duration = duration
        opacity.repeatCount = Float.infinity
        opacity.fillMode = CAMediaTimingFillMode.removed
        opacity.timingFunction = opacity_timing
        opacity.fromValue = echoBeginOpacity
        opacity.toValue = echoEndOpacity
        layer.add(opacity, forKey:"echoOpacity")
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        (layer as! CMRingLayer).echoOpacity = echoEndOpacity
        CATransaction.commit()
    }
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) 
    {
        if (anim as? CABasicAnimation)?.keyPath == "ringRadius" {completionBlock()}
    }
    
// MARK: - DRAW
    
    override func draw(_ layer: CALayer, in ctx: CGContext)
    {
        guard let ring = ringGeometry else {return}
        let ring_radius = (layer as! CMRingLayer).ringRadius
        let control_radius = (layer as! CMRingLayer).aperture
        let echo_radius = (layer as! CMRingLayer).echo
        let echo_opacity = (layer as! CMRingLayer).echoOpacity
        UIGraphicsPushContext(ctx)
        CoachRingRenderer.drawCoachRing(ringColor: ringMainColor,
                                        controlRadius: control_radius, 
                                        controlCenter: ring.controlCenter, 
                                        ringRadius: ring_radius, 
                                        ringCenter: ring.center)
        
        CoachRingRenderer.drawCoachRingEcho(ringEchoColor: ringEchoColor, 
                                            controlRadius: control_radius, 
                                            ringRadius: echo_radius, 
                                            ringCenter: ring.center, 
                                            echoOpacity: echo_opacity)
        UIGraphicsPopContext()
    }
    
// MARK: - SETUP AND BACKSTORE
    
    var ringGeometry:CoachRing?
    
    var ringMainColor:UIColor = UIColor(red:0.000, green:0.387, blue:0.742, alpha: 0.8)
    var ringEchoColor:UIColor = UIColor.white
    
    var ringPeriod:Double        = 0.3
    var aperturePeriod:Double    = 0.4
    var apertureTravel:CGFloat   = 10
    var echoTravel:CGFloat       = 30
    var echoBeginOpacity:CGFloat = 0.6
    var echoEndOpacity:CGFloat   = 0.0
    
    private var completionBlock:()->Void = {}
    
    override class var layerClass : AnyClass
    {
        return CMRingLayer.self
    }
}

// MARK: - LAYER

class CMRingLayer: CALayer
{
    @NSManaged var ringRadius: CGFloat
    @NSManaged var aperture: CGFloat
    @NSManaged var echo: CGFloat
    @NSManaged var echoOpacity: CGFloat
    
    override class func needsDisplay(forKey key: (String)) -> Bool
    {
        if key == "ringRadius" || 
           key == "aperture"   ||
           key == "echo"       ||
           key == "echoOpacity"    {return true}
        else                       {return super.needsDisplay(forKey: key)}
    }
    
    override func action(forKey event: (String)) -> (CAAction)
    {
        if event == "ringRadius"  || 
           event == "aperture"    ||
           event == "echo"        ||
           event == "echoOpacity"
        {
            let animation = CABasicAnimation.init(keyPath:event)
            animation.fromValue = presentation()?.value(forKey: event)
            return animation
        }
        return super.action(forKey: event)!
    }
    
    override init()
    {
        super.init()
        ringRadius = 0.0
        aperture = 0.0
        echo = 0.0
        echoOpacity = 1.0
    }
    override init(layer: Any)
    {
        super.init(layer: layer)
        if let layer = layer as? CMRingLayer 
        {
            ringRadius = layer.ringRadius
            aperture = layer.aperture
            echo = layer.echo
            echoOpacity = layer.echoOpacity
        }
    }
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}
