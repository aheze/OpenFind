//
//  PermissionsVC+Gestures.swift
//  FindAppClip1
//
//  Created by Zheng on 3/15/21.
//

import UIKit

extension PermissionsViewController {
    func handlePan(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            if began {
                let currentYPosition = permissionsView.layer.presentation()?.affineTransform().ty ?? 0
                
                if currentYPosition > 0 {
                    let currentYOffset = pow(currentYPosition, 1 / Constants.rubberBandingPower)
                    savedOffset = currentYOffset
                } else {
                    let currentYOffset = pow(abs(currentYPosition), 1 / Constants.rubberBandingPower)
                    savedOffset = -currentYOffset
                }
                animator?.stopAnimation(true)
            } else {
                began = true
            }
        case .changed:
            let yPosition = sender.translation(in: view).y + savedOffset
            
            if yPosition > 0 {
                let adjustedValue = pow(yPosition, Constants.rubberBandingPower)
                permissionsView.transform = CGAffineTransform(translationX: 0, y: adjustedValue)
                permissionsBottomView.transform = CGAffineTransform(scaleX: 1, y: 0)
            } else {
                let adjustedValue = pow(abs(yPosition), Constants.rubberBandingPower)
                permissionsView.transform = CGAffineTransform(translationX: 0, y: -adjustedValue)
                
                permissionsBottomView.transform = CGAffineTransform(scaleX: 1, y: 1 + (adjustedValue / permissionsBottomView.bounds.height * 2))
            }
            
        case .ended:
            panEnded()
        case .cancelled:
            animator?.stopAnimation(true)
        default:
            print("default launch pan")
        }
    }
    
    func panEnded() {
        
        let timingParameters = UISpringTimingParameters(damping: 1, response: Constants.animationDuration, initialVelocity: CGVector.zero)
        animator = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters)
        
        animator?.addAnimations {
            self.permissionsView.transform = CGAffineTransform(translationX: 0, y: 0)
            self.permissionsBottomView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        animator?.startAnimation()
        animator?.addCompletion({ _ in
            self.savedOffset = 0
            self.began = false
        })
    }
}
