//
//  VC+GestureAnimations.swift
//  FindAppClip1
//
//  Created by Zheng on 3/18/21.
//

import UIKit

extension ViewController {
    func releasedPan(at currentY: CGFloat, velocity: CGFloat) {
        
        let sheetBottomPosition = view.bounds.height + currentY
        
        let decelerationRate = UIScrollView.DecelerationRate.normal.rawValue
        
        let projectedPosition = sheetBottomPosition + project(initialVelocity: velocity, decelerationRate: decelerationRate)
        
        let centerY = view.frame.height / 2
        let finalY: CGFloat
        
        if projectedPosition <= centerY {
            finalY = -view.bounds.height + Positions.topStop
        } else {
            finalY = 0
        }

        let relativeV = CGVector(
            dx: 0,
            dy: relativeVelocity(forVelocity: velocity, from: sheetBottomPosition, to: finalY)
        )
        
        let block = {
            self.cameraContainerView.transform = CGAffineTransform(
                translationX: 0,
                y:
                    finalY
            )
            self.cameraViewController.cameraContentView.transform = CGAffineTransform(
                scaleX: 1,
                y: 1
            )
            
            if finalY == 0 {
                self.downloadCoverView.alpha = 1
            }
        }
        
        
        let timingParameters = UISpringTimingParameters(damping: 1, response: Constants.animationDuration, initialVelocity: relativeV)
        animator = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters)
        
        animator?.addAnimations(block)
        animator?.startAnimation()
        animator?.addCompletion({ _ in
            GestureState.savedOffset = finalY
            GestureState.began = false
            
            CurrentState.currentlyPresenting = !(finalY == 0) /// if finalY is 0, then it's normal
            
            self.updateStatusBar?()
            
            UIView.animate(withDuration: 0.2) {
                self.cameraViewController.cameraMaskView.backgroundColor = CurrentState.currentlyPresenting ? UIColor.blue.withAlphaComponent(0) : UIColor.blue.withAlphaComponent(0.3)
                
                self.cameraViewController.morphingLabel.alpha = CurrentState.currentlyPresenting ? 0 : 1
                self.cameraViewController.gradientView.alpha = 0
                self.cameraViewController.overlayShadowView.alpha = 0

                if CurrentState.currentlyPresenting {
                    self.cameraViewController.goBackButton.alpha = 1
                    self.cameraViewController.controlsBaseView.alpha = 0
                    self.cameraViewController.pauseLivePreview()
                    if !CurrentState.presentingOverlay {
                        self.displayOverlay()
                    }
                    self.downloadCoverView.alpha = 0
                } else {
                    self.cameraViewController.morphingLabel.finish()
                    self.cameraViewController.morphingLabel.text = "Get the full app"
                    self.cameraViewController.getButton.isEnabled = true
                    if CurrentState.presentingOverlay {
                        self.dismissOverlay()
                    }
                    
                    self.downloadCoverView.alpha = 1
                }
            }
        })
        
        let progress = -currentY / (view.bounds.height - Positions.topStop)
        
        blurAnimator?.isReversed = (finalY == 0)
        blurAnimator?.continueAnimation(withTimingParameters: nil, durationFactor: Constants.animationDuration)
    }
    
    /// Distance traveled after decelerating to zero velocity at a constant rate.
    func project(initialVelocity: CGFloat, decelerationRate: CGFloat) -> CGFloat {
        return (initialVelocity / 1000) * decelerationRate / (1 - decelerationRate)
    }
    
    /// Calculates the relative velocity needed for the initial velocity of the animation.
    func relativeVelocity(forVelocity velocity: CGFloat, from currentValue: CGFloat, to targetValue: CGFloat) -> CGFloat {
        guard currentValue - targetValue != 0 else { return 0 }
        return velocity / (targetValue - currentValue)
    }
}
