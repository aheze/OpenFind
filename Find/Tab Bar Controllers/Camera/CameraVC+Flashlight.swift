//
//  CameraVC+Flashlight.swift
//  Find
//
//  Created by Zheng on 3/5/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension CameraViewController {
    
    /// lock when preview is paused
    func lockFlashlight(lock: Bool) {
        flashButton.isEnabled = !lock
        flashDisableIcon.animateSlash(lock: lock)
        UIView.animate(withDuration: 0.5) {
            self.flashImageView.alpha = lock ? 0.5 : 1
        }
        
        if flashlightOn {
            if lock {
                toggleFlashlight(false)
            } else {
                toggleFlashlight(true)
            }
        }
    }
    
    func toggleFlashlight(_ on: Bool) {
        guard
            let device = cameraDevice,
            device.hasTorch
        else {

            return
        }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            device.unlockForConfiguration()
        } catch {

        }
        
        flashView.accessibilityValue = on ? "On" : "Off"
        
        let flashlightImage = on ? UIImage(systemName: "flashlight.on.fill") : UIImage(systemName: "flashlight.off.fill")
        UIView.transition(
            with: flashImageView,
            duration: 0.75,
            options: .transitionCrossDissolve,
            animations: { self.flashImageView.image = flashlightImage },
            completion: nil
        )
        
        UIView.animate(withDuration: 0.3) {
            self.flashView.backgroundColor = on ? #colorLiteral(red: 0.5, green: 0.4678574155, blue: 0, alpha: 0.75) : UIColor(named: "50Black")
        }
        
    }
}

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

