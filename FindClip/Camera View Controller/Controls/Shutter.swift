//
//  Shutter.swift
//  FindAppClip1
//
//  Created by Zheng on 3/13/21.
//

import UIKit

class Shutter: UIView {
    var pressed: (() -> Void)?
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var containerView: UIView! /// contains rim and fill
    @IBOutlet var rimView: UIView!
    @IBOutlet var fillView: UIView!
    var shapeFillLayer: CAShapeLayer?
    
    @IBOutlet var touchButton: UIButton!
    
    @IBAction func touchDown(_ sender: Any) {
        UIView.animate(withDuration: 0.2, animations: {
            self.contentView.alpha = 0.5
            self.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        })
    }

    @IBAction func touchUpInside(_ sender: Any) {
        pressed?()
        resetAlpha()
    }

    @IBAction func touchUpCancel(_ sender: Any) {
        resetAlpha()
    }

    func resetAlpha() {
        UIView.animate(withDuration: 0.2, animations: {
            self.contentView.alpha = 1
            self.transform = CGAffineTransform.identity
        })
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("Shutter", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let fillLayer = CAShapeLayer()
        fillLayer.position = CGPoint(x: fillView.bounds.width / 2, y: fillView.bounds.width / 2)
        shapeFillLayer = fillLayer
        fillView.layer.mask = fillLayer
        
        let circlePath = createRoundedCircle(circumference: fillView.bounds.width, cornerRadius: fillView.bounds.width / 2)
        fillLayer.path = circlePath
        
        rimView.layer.borderWidth = 4
        rimView.layer.borderColor = UIColor.white.cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rimView.layer.cornerRadius = rimView.frame.width / 2
    }
   
    func toggle(on: Bool) {
        if on {
            let trianglePath = createRoundedTriangle(circumference: fillView.bounds.width)
            
            let pathAnimation = CABasicAnimation(keyPath: "path")
            pathAnimation.fromValue = shapeFillLayer?.path
            pathAnimation.toValue = trianglePath
            
            shapeFillLayer?.path = trianglePath
            pathAnimation.duration = 0.2
            pathAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            
            shapeFillLayer?.add(pathAnimation, forKey: "pathAnimation")
        } else {
            let circlePath = createRoundedCircle(circumference: fillView.bounds.width, cornerRadius: fillView.bounds.width / 2)
            
            let pathAnimation = CABasicAnimation(keyPath: "path")
            pathAnimation.fromValue = shapeFillLayer?.path
            pathAnimation.toValue = circlePath
            
            shapeFillLayer?.path = circlePath
            pathAnimation.duration = 0.2
            pathAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            
            shapeFillLayer?.add(pathAnimation, forKey: "pathAnimation")
        }
    }
    
    func createRoundedTriangle(circumference: CGFloat) -> CGPath {
        let cornerRadius = circumference / 10
        
        let width = circumference / 2
        let xLeft = width / 30
        let yOffset = sqrt(3) * (width / 2)
        
        let point1 = CGPoint(x: (-width / 2) - xLeft, y: -yOffset)
        let point2 = CGPoint(x: width - xLeft, y: 0)
        let point3 = CGPoint(x: (-width / 2) - xLeft, y: yOffset)
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: (-width / 2) - xLeft, y: 0))
        path.addArc(tangent1End: point1, tangent2End: point2, radius: cornerRadius)
        path.addArc(tangent1End: point2, tangent2End: point3, radius: cornerRadius)
        path.addArc(tangent1End: point3, tangent2End: point1, radius: cornerRadius)
        path.closeSubpath()
        
        return path
    }
    
    func createRoundedCircle(circumference: CGFloat, cornerRadius: CGFloat) -> CGPath {
        let yOffset = sqrt(3) * (circumference / 2)
        
        let point1 = CGPoint(x: -circumference / 2, y: -yOffset)
        let point2 = CGPoint(x: circumference, y: 0)
        let point3 = CGPoint(x: -circumference / 2, y: yOffset)
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -circumference / 2, y: 0))
        
        path.addArc(tangent1End: point1, tangent2End: point2, radius: cornerRadius)
        path.addArc(tangent1End: point2, tangent2End: point3, radius: cornerRadius)
        path.addArc(tangent1End: point3, tangent2End: point1, radius: cornerRadius)
        path.closeSubpath()
        
        return path
    }
}
