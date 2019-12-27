
//
//  CameraButton.swift
//  TenStats
//
//  Created by Olivier Destrebecq on 1/16/16.
//  Copyright © 2016 MobDesign. All rights reserved.
//



/*
 The MIT License (MIT)
 Copyright (c) 2015 Kyohei Yamaguchi
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import UIKit

@objc
@IBDesignable
open class ShutterButton: UIButton {
    
    @objc
    public enum ShutterType: Int {
        case normal, slowMotion, timeLapse
    }
    
    @objc
    public enum ButtonState: Int {
        case normal, recording
    }
    
    private let _kstartAnimateDuration: CFTimeInterval = 0.5
    
    /**************************************************************************/
    // MARK: - Properties
    /**************************************************************************/
    
    @objc
    @IBInspectable var typeRaw: Int = 0 {
        didSet {
            if let type = ShutterType(rawValue: typeRaw) {
                self.shutterType = type
            } else {
                self.shutterType = .normal
            }
        }
    }
    
    @objc
    @IBInspectable public var buttonColor: UIColor = UIColor.red {
        didSet {
            _circleLayer.fillColor = buttonColor.cgColor
        }
    }
    
    @objc
    @IBInspectable public var arcColor: UIColor = UIColor.white {
        didSet {
            _arcLayer.strokeColor = arcColor.cgColor
        }
    }
    
    @objc
    @IBInspectable public var progressColor: UIColor = UIColor.white {
        didSet {
            _progressLayer.strokeColor = progressColor.cgColor
            _rotateLayer.strokeColor   = progressColor.cgColor
        }
    }
    
    @objc
    @IBInspectable public var rotateAnimateDuration: Float = 5 {
        didSet {
            _recordingRotateAnimation.duration = TimeInterval(rotateAnimateDuration)
            _recordingAnimation.duration       = TimeInterval(rotateAnimateDuration*2)
        }
    }
    
    @objc
    public var buttonState: ButtonState = .normal {
        didSet {
            let animation = CABasicAnimation(keyPath: "path")
            animation.fromValue = _circleLayer.path
            animation.duration  = 0.15
            
            switch buttonState {
            case .normal:
                if shutterType == .timeLapse {
                    p_removeTimeLapseAnimations()
                }
                animation.toValue = _circlePath.cgPath
                _circleLayer.add(animation, forKey: "path-anim")
                _circleLayer.path = _circlePath.cgPath
            case .recording:
                animation.toValue = _roundRectPath.cgPath
                _circleLayer.add(animation, forKey: "path-anim")
                _circleLayer.path = _roundRectPath.cgPath
                if shutterType == .timeLapse {
                    p_addTimeLapseAnimations()
                }
            }
        }
    }
    
    @objc
    public var shutterType: ShutterType  = .normal {
        didSet {
            updateLayers()
        }
    }
    
    private var _arcWidth: CGFloat {
        return bounds.width * 0.09090
    }
    
    private var _arcMargin: CGFloat {
        return bounds.width * 0.03030
    }
    
    lazy private var _circleLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.path      = self._circlePath.cgPath
        layer.fillColor = self.buttonColor.cgColor
        return layer
    }()
    
    lazy private var _arcLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.path        = self._arcPath.cgPath
        layer.fillColor   = UIColor.clear.cgColor
        layer.strokeColor = self.arcColor.cgColor
        layer.lineWidth   = self._arcWidth
        return layer
    }()
    
    lazy private var _progressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        let path  = self.p_arcPathWithProgress(1.0, clockwise: true)
        layer.path            = path.cgPath
        layer.fillColor       = UIColor.clear.cgColor
        layer.strokeColor     = self.progressColor.cgColor
        layer.lineWidth       = self._arcWidth/1.5
        return layer
    }()
    
    lazy private var _rotateLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = self.progressColor.cgColor
        layer.lineWidth   = 1
        layer.path        = self._rotatePath.cgPath
        layer.frame       = self.bounds
        return layer
    }()
    
    private var _circlePath: UIBezierPath {
        let side = self.bounds.width - self._arcWidth*2 - self._arcMargin*2
        return UIBezierPath(
            roundedRect: CGRect(x: bounds.width/2 - side/2, y: bounds.width/2 - side/2, width: side, height: side),
            cornerRadius: side/2
        )
    }
    
    private var _arcPath: UIBezierPath {
        return UIBezierPath(
            arcCenter: CGPoint(x: self.bounds.midX, y: self.bounds.midY),
            radius: self.bounds.width/2 - self._arcWidth/2,
            startAngle: -.pi/2,
            endAngle: .pi*2 - .pi/2,
            clockwise: true
        )
    }
    
//     private var _roundRectPath: UIBezierPath {
//         let side = bounds.width * 0.4242
//         return UIBezierPath(
//             roundedRect: CGRect(x: bounds.width/2 - side/2, y: bounds.width/2 - side/2, width: side, height: side),
//             cornerRadius: side * 0.107
//         )
//     }
    private var _roundRectPath: UIBezierPath {
        let size = bounds.width * 0.38
        let newWidth = sqrt(pow(size, 2) - pow((size/2), 2)
        let cgPath = createRoundedTriangle(width: newWidth, height: size)
        let trianglePath = UIBezierPath(cgPath: cgPath)
        return trianglePath
    }
  func createRoundedTriangle(width: CGFloat, height: CGFloat, radius: CGFloat) -> CGPath {
     let point1 = CGPoint(x: -width / 2, y: height / 2)
     let point2 = CGPoint(x: 0, y: -height / 2)
     let point3 = CGPoint(x: width / 2, y: height / 2)

     let path = CGMutablePath()
     path.move(to: CGPoint(x: 0, y: height / 2))
     path.addArc(tangent1End: point1, tangent2End: point2, radius: radius)
     path.addArc(tangent1End: point2, tangent2End: point3, radius: radius)
     path.addArc(tangent1End: point3, tangent2End: point1, radius: radius)
     path.closeSubpath()

     return path
 }
    
    private var _rotatePath: UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: self.bounds.width/2, y: 0))
        path.addLine(to: CGPoint(x: self.bounds.width/2, y: self._arcWidth))
        return path
    }
    
    private var _startProgressAnimation: CAKeyframeAnimation {
        let frameCount = 60
        var paths = [CGPath]()
        var times = [CGFloat]()
        for i in 1...frameCount {
            let animationProgress = 1/CGFloat(frameCount) * CGFloat(i) - 0.01
            paths.append(self.p_arcPathWithProgress(animationProgress, clockwise: false).cgPath)
            times.append(CGFloat(i)*0.1)
        }
        let animation         = CAKeyframeAnimation(keyPath: "path")
        animation.duration    = _kstartAnimateDuration
        animation.values      = paths
        return animation
    }
    
    private var _startRotateAnimation: CABasicAnimation {
        let animation         = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue   = 0
        animation.toValue     = CGFloat.pi*2
        animation.duration    = _kstartAnimateDuration
        return animation
    }
    
    private var _recordingAnimation: CAKeyframeAnimation {
        let frameCount = 60
        var paths = [CGPath]()
        for i in 1...frameCount {
            let animationProgress = 1/CGFloat(frameCount) * CGFloat(i)
            paths.append(self.p_arcPathWithProgress(animationProgress).cgPath)
        }
        for i in 1...frameCount {
            let animationProgress = 1/CGFloat(frameCount) * CGFloat(i) - 0.01
            paths.append(self.p_arcPathWithProgress(animationProgress, clockwise: false).cgPath)
        }
        let animation         = CAKeyframeAnimation(keyPath: "path")
        animation.duration    = TimeInterval(rotateAnimateDuration*2)
        animation.values      = paths
        animation.beginTime   = CACurrentMediaTime() + _kstartAnimateDuration
        animation.repeatCount = Float.infinity
        animation.calculationMode = CAAnimationCalculationMode.discrete
        return animation
    }
    
    private var _recordingRotateAnimation: CABasicAnimation {
        let animation         = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue   = 0
        animation.toValue     = CGFloat.pi*2
        animation.duration    = TimeInterval(rotateAnimateDuration)
        animation.repeatCount = Float.infinity
        animation.beginTime   = CACurrentMediaTime() + _kstartAnimateDuration
        return animation
    }
    
    
    /**************************************************************************/
    // MARK: - initialize
    /**************************************************************************/
    
    @objc
    public convenience init(frame: CGRect, shutterType: ShutterType, buttonColor: UIColor) {
        self.init(frame: frame)
        self.shutterType = shutterType
        self.buttonColor = buttonColor
    }
    
    /**************************************************************************/
    // MARK: - Override
    /**************************************************************************/
    
    @objc
    override open var isHighlighted: Bool {
        didSet {
            _circleLayer.opacity = isHighlighted ? 0.5 : 1.0
        }
    }
    
    @objc
    open override func layoutSubviews() {
        super.layoutSubviews()
        if _arcLayer.superlayer != layer {
            layer.addSublayer(_arcLayer)
        } else {
            _arcLayer.path      = _arcPath.cgPath
            _arcLayer.lineWidth = _arcWidth
        }
        
        if _progressLayer.superlayer != layer {
            layer.addSublayer(_progressLayer)
        } else {
            _progressLayer.path      = p_arcPathWithProgress(1).cgPath
            _progressLayer.lineWidth = _arcWidth/1.5
        }
        
        if _rotateLayer.superlayer != layer {
            layer.insertSublayer(_rotateLayer, at: 0)
        } else {
            _rotateLayer.path  = _rotatePath.cgPath
            _rotateLayer.frame = self.bounds
        }
        
        if _circleLayer.superlayer != layer {
            layer.addSublayer(_circleLayer)
        } else {
            switch buttonState {
            case .normal:    _circleLayer.path = _circlePath.cgPath
            case .recording: _circleLayer.path = _roundRectPath.cgPath
            }
        }
        
        if shutterType == .timeLapse && buttonState == .recording {
            p_removeTimeLapseAnimations()
            p_addTimeLapseAnimations()
        }
        
        updateLayers()
    }
    
    @objc
    open override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle("", for: state)
    }
    
    /**************************************************************************/
    // MARK: - Method
    /**************************************************************************/
    
    private func p_addTimeLapseAnimations() {
        _progressLayer.add(_startProgressAnimation, forKey: "start-anim")
        _rotateLayer.add(_startRotateAnimation, forKey: "rotate-anim")
        _progressLayer.add(_recordingAnimation, forKey: "recording-anim")
        _rotateLayer.add(_recordingRotateAnimation, forKey: "recordingRotate-anim")
        _progressLayer.path = p_arcPathWithProgress(1.0).cgPath
    }
    
    private func p_removeTimeLapseAnimations() {
        _progressLayer.removeAllAnimations()
        _rotateLayer.removeAllAnimations()
    }
    
    private func p_arcPathWithProgress(_ progress: CGFloat, clockwise: Bool = true) -> UIBezierPath {
        let diameter = 2*CGFloat.pi*(self.bounds.width/2 - self._arcWidth/3)
        let startAngle = clockwise ?
            -CGFloat.pi/2 :
            -CGFloat.pi/2 + CGFloat.pi*(540/diameter)/180
        let endAngle   = clockwise ?
            CGFloat.pi*2*progress - CGFloat.pi/2 :
            CGFloat.pi*2*progress - CGFloat.pi/2 + CGFloat.pi*(540/diameter)/180
        let path = UIBezierPath(
            arcCenter: CGPoint(x: self.bounds.midX, y: self.bounds.midY),
            radius: self.bounds.width/2 - self._arcWidth/3,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: clockwise
        )
        return path
    }
    
    private func updateLayers() {
        switch shutterType {
        case .normal:
            _arcLayer.lineDashPattern = nil
            _progressLayer.isHidden     = true
        case .slowMotion:
            _arcLayer.lineDashPattern = [1, 1]
            _progressLayer.isHidden     = true
        case .timeLapse:
            let diameter = CGFloat.pi*(self.bounds.width/2 - self._arcWidth/2)
            let progressDiameter = 2*CGFloat.pi*(self.bounds.width/2 - self._arcWidth/3)
            
            _arcLayer.lineDashPattern = [1, NSNumber(value: (diameter/10 - 1).native)]
            _progressLayer.lineDashPattern = [1, NSNumber(value: (progressDiameter/60 - 1).native)]
            _progressLayer.isHidden     = false
        }
    }
    
}






//import UIKit
//
//@IBDesignable
//class CameraButton: UIButton {
//    //create a new layer to render the various circles
//    var pathLayer:CAShapeLayer!
//    let animationDuration = 0.3
//
//    override init(frame: CGRect) {
//
//        super.init(frame: frame)
//
//        self.setup()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//
//        self.setup()
//    }
//
//    //common set up code
//    func setup()
//    {
//        //add a shape layer for the inner shape to be able to animate it
//        self.pathLayer = CAShapeLayer()
//
//        //show the right shape for the current state of the control
//        self.pathLayer.path = self.currentInnerPath().cgPath
//
//        //don't use a stroke color, which would give a ring around the inner circle
//        self.pathLayer.strokeColor = nil
//
//        //set the color for the inner shape
//        self.pathLayer.fillColor = UIColor.blue.cgColor
//
//        //add the path layer to the control layer so it gets drawn
//        self.layer.addSublayer(self.pathLayer)
//    }
//
//    override func awakeFromNib()
//    {
//        super.awakeFromNib()
//
//        //lock the size to match the size of the camera button
//        self.addConstraint(NSLayoutConstraint(item: self,
//                                              attribute:.width,
//                                              relatedBy:.equal,
//                                              toItem:nil,
//                                              attribute:.width,
//                                              multiplier:1,
//                                              constant:75.0))
//        self.addConstraint(NSLayoutConstraint(item: self,
//                                              attribute:.height,
//                                              relatedBy:.equal,
//                                              toItem:nil,
//                                              attribute:.width,
//                                              multiplier:1,
//                                              constant:75.0))
//
//        //clear the title
//        self.setTitle("", for:UIControl.State.normal)
//        self.backgroundColor = UIColor.clear
//
//        //add out target for event handling
//        self.addTarget(self, action: #selector(touchUpInside), for: UIControl.Event.touchUpInside)
//        self.addTarget(self, action: #selector(touchDown), for: UIControl.Event.touchDown)
//    }
//
//
//    override func prepareForInterfaceBuilder()
//    {
//        //clear the title
//        self.setTitle("", for:UIControl.State.normal)
//    }
//
//    override var isSelected:Bool{
//        didSet{
//            //change the inner shape to match the state
//            let morph = CABasicAnimation(keyPath: "path")
//            morph.duration = animationDuration;
//            morph.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
//
//            //change the shape according to the current state of the control
//            morph.toValue = self.currentInnerPath().cgPath
//
//            //ensure the animation is not reverted once completed
//            morph.fillMode = CAMediaTimingFillMode.forwards
//            morph.isRemovedOnCompletion = false
//
//            //add the animation
//            self.pathLayer.add(morph, forKey:"")
//        }
//    }
//
//    @objc func touchUpInside(sender:UIButton)
//    {
//        //Create the animation to restore the color of the button
//        let colorChange = CABasicAnimation(keyPath: "fillColor")
//        colorChange.duration = animationDuration;
//        colorChange.toValue = UIColor.blue.cgColor
//
//        //make sure that the color animation is not reverted once the animation is completed
//        colorChange.fillMode = CAMediaTimingFillMode.forwards
//        colorChange.isRemovedOnCompletion = false
//
//        //indicate which animation timing function to use, in this case ease in and ease out
//        colorChange.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
//
//        //add the animation
//        self.pathLayer.add(colorChange, forKey:"darkColor")
//
//        //change the state of the control to update the shape
//        self.isSelected = !self.isSelected
//    }
//
//    @objc func touchDown(sender:UIButton)
//    {
//        //when the user touches the button, the inner shape should change transparency
//        //create the animation for the fill color
//        let morph = CABasicAnimation(keyPath: "fillColor")
//        morph.duration = animationDuration;
//
//        //set the value we want to animate to
//        morph.toValue = UIColor(red: 0, green: 0.2, blue: 1, alpha: 0.5).cgColor
//
//
//        //ensure the animation does not get reverted once completed
//        morph.fillMode = CAMediaTimingFillMode.forwards
//        morph.isRemovedOnCompletion = false
//
//        morph.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
//        self.pathLayer.add(morph, forKey:"")
//    }
//
//    override func draw(_ rect: CGRect) {
//        //always draw the outer ring, the inner control is drawn during the animations
//        let outerRing = UIBezierPath(ovalIn: CGRect(x:3, y:3, width:69, height:69))
//        outerRing.lineWidth = 6
////        outerRing.fill(with: CGBlendMode.clear, alpha: 0)
//        UIColor.white.setStroke()
//        outerRing.stroke()
//    }
//
//    func currentInnerPath () -> UIBezierPath
//    {
//        //choose the correct inner path based on the control state
//        var returnPath:UIBezierPath;
//        if (self.isSelected)
//        {
//            returnPath = self.innerSquarePath()
//        }
//        else
//        {
//            returnPath = self.innerCirclePath()
//        }
//
//        return returnPath
//    }
//
//    func innerCirclePath () -> UIBezierPath
//    {
//        return UIBezierPath(roundedRect: CGRect(x:8, y:8, width:59, height:59), cornerRadius: 29.5)
//    }
//
//    func innerSquarePath () -> UIBezierPath
//    {
//        return UIBezierPath(roundedRect: CGRect(x:18, y:18, width:39, height:39), cornerRadius: 5)
//    }
//}
