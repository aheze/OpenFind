//
//  VC+GestureHandlers.swift
//  FindAppClip1
//
//  Created by Zheng on 3/13/21.
//

import UIKit

extension ViewController {
    func longPressed(sender: UILongPressGestureRecognizer) {
        var currentYPosition = cameraContainerView.layer.presentation()?.affineTransform().ty ?? 0
        
        if currentYPosition == 0 {
            let currentScale = scale(from: cameraViewController.cameraContentView.layer.presentation()?.affineTransform() ?? CGAffineTransform.identity)
            
            let currentScaleOffset = CGFloat(currentScale) - 1
            
            /// y position after the rubber band power
            let adjustedYPosition = currentScaleOffset * 200
            
            currentYPosition = pow(adjustedYPosition, 1 / Constants.rubberBandingPower)
        } else if currentYPosition < -view.bounds.height + Positions.topStop {
            /// actual negative y offset of the view on screen, is less than actual pan distance
            let adjustedYOffset = view.bounds.height - Positions.topStop + currentYPosition
            
            let currentYOffset = pow(abs(adjustedYOffset), 1 / Constants.rubberBandingPower)
            
            currentYPosition = -currentYOffset - view.bounds.height + Positions.topStop
        }
        
        if sender.state == .began {
            animator?.stopAnimation(true)
            
            GestureState.savedOffset = currentYPosition
            GestureState.startedPan = false /// reset at long press
            
            let progress = -currentYPosition / (view.bounds.height - Positions.topStop)
            
            blurAnimator?.pauseAnimation()
            blurAnimator?.isReversed = false
            blurAnimator?.fractionComplete = progress
        } else if sender.state == .ended || sender.state == .cancelled {
            if GestureState.startedPan == false {
                releasedPan(at: currentYPosition, velocity: 0)
            }
        }
    }

    func panned(sender: UIPanGestureRecognizer) {
        let yPosition = sender.translation(in: view).y + GestureState.savedOffset
        
        switch sender.state {
        case .began:
            if !GestureState.began {
                blurCamera()
                if CurrentState.currentlyPresenting, !CurrentState.currentlyPaused {
                    cameraViewController.startLivePreview()
                }
            }
            GestureState.began = true
            GestureState.startedPan = true
            
            UIView.animate(withDuration: 0.2) {
                self.cameraViewController.cameraMaskView.backgroundColor = UIColor.blue.withAlphaComponent(0)
                self.cameraViewController.overlayShadowView.alpha = 1
                
                self.cameraViewController.morphingLabel.alpha = 1
                self.cameraViewController.goBackButton.alpha = 0
                self.downloadCoverView.alpha = 0
                
                if CurrentState.currentlyPresenting {
                    self.cameraViewController.controlsBaseView.alpha = 1
                }
            }
            
            if CurrentState.currentlyPresenting {
                cameraViewController.morphingLabel.text = "Thanks for checking it out!"
                cameraViewController.morphingLabel.pause()
                cameraViewController.morphingLabel.updateProgress(progress: 1)
            }
            
            cameraViewController.getButton.isEnabled = false
        case .changed:
            switch yPosition {
            /// scale camera view
            case let y where y > 0:
                cameraContainerView.transform = CGAffineTransform(
                    translationX: 0,
                    y: 0
                )
                
                let adjustedValue = pow(y, Constants.rubberBandingPower)
                cameraViewController.cameraContentView.transform = CGAffineTransform(
                    scaleX: 1 + adjustedValue / 200,
                    y: 1 + adjustedValue / 200
                )
                
            /// rubber band the top
            case let y where y < -view.bounds.height + Positions.topStop:
                
                /// still negative value
                let overflow = view.bounds.height - Positions.topStop + y
                
                /// positive now
                let adjustedValue = pow(abs(overflow), Constants.rubberBandingPower)
                
                cameraContainerView.transform = CGAffineTransform(
                    translationX: 0,
                    y: -adjustedValue - view.bounds.height + Positions.topStop
                )
                
            default:
                cameraContainerView.transform = CGAffineTransform(
                    translationX: 0,
                    y: yPosition
                )
                cameraViewController.cameraContentView.transform = CGAffineTransform(
                    scaleX: 1,
                    y: 1
                )
                
                let progress = -yPosition / (view.bounds.height - Positions.topStop)
                if progress > 0.5, !CurrentState.presentingOverlay {
                    displayOverlay()
                } else if progress < 0.5, CurrentState.presentingOverlay {
                    dismissOverlay()
                }
                
                blurAnimator?.fractionComplete = progress
            }
            
        case .ended:
            
            GestureState.savedOffset = yPosition
            
            let velocity = sender.velocity(in: view)
            releasedPan(at: yPosition, velocity: velocity.y)
        case .cancelled:
            animator?.stopAnimation(true)
        default:
            break
        }
    }
}
