//
//  GestureTransitions.swift
//  FindTabBar
//
//  Created by Zheng on 12/20/20.
//

import UIKit

extension ViewController {
    func stopScroll(_ scrollView: UIScrollView?) {
        scrollView?.isScrollEnabled = false
        scrollView?.isScrollEnabled = true
    }
    
    func moveRubberBand(totalValue: CGFloat) {
        if gestures.direction == .left { /// in Lists, hitting right edge
            let safeTotalValue = min(0, totalValue)
            let adjustedValue = -pow(-safeTotalValue, FindConstants.rubberBandingPower)
            ViewControllerState.currentVC?.view.frame.origin.x = adjustedValue
        } else if gestures.direction == .right { /// in Photos, hitting left edge
            let safeTotalValue = max(0, totalValue)
            let adjustedValue = pow(safeTotalValue, FindConstants.rubberBandingPower)
            ViewControllerState.currentVC?.view.frame.origin.x = adjustedValue
        }
    }
    
    func finishMoveRubberBand(totalValue: CGFloat, velocity: CGFloat) {
        let maximumTotalValue = min(abs(totalValue), 200)
        let adjustedValue = pow(maximumTotalValue, FindConstants.rubberBandingPower)
        
        gestures.framePositionWhenLifted = ViewControllerState.currentVC?.view.frame.origin.x ?? 0
        gestures.viewToTrackChanges = ViewControllerState.currentVC?.view
        gestures.isAnimating = true

        let decelerationRate = UIScrollView.DecelerationRate.normal.rawValue
        
        let projectedPosition = adjustedValue + project(initialVelocity: velocity, decelerationRate: decelerationRate)
        let relativeV = CGVector(
            dx: relativeVelocity(forVelocity: velocity, from: projectedPosition, to: 0),
            dy: 0
        )
        
        let timingParameters = UISpringTimingParameters(damping: 1, response: FindConstants.transitionDuration, initialVelocity: relativeV)
        animator = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters)
        animator?.addAnimations {
            ViewControllerState.currentVC?.view.frame.origin.x = 0
        }
        animator?.addCompletion { _ in
            self.gestures.direction = nil
            self.gestures.isAnimating = false
            self.gestures.totalTranslation = 0
            self.gestures.isRubberBanding = false
            self.gestures.gestureSavedOffset = 0
        }
        animator?.startAnimation()
    }
    
    func startMoveVC(from fromVC: UIViewController, to toVC: UIViewController, direction: Direction, toOverlay: Bool = true) {
        camera.focusGestureRecognizer?.isEnabled = false
        camera.focusGestureRecognizer?.isEnabled = true
        
        addChild(toVC)
        containerView.addSubview(toVC.view)
        toVC.view.frame = containerView.bounds
        toVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        if tabBarView.animatingObjects > 0 {
            tabBarView.gestureInterruptedButton = true
        }
        
        blurAnimator?.stopAnimation(true)
        blurAnimator?.finishAnimation(at: .end)
        
        if direction == .left {
            if toOverlay { /// camera to lists
                tabBarView.getBlocks(from: fromVC, to: .lists).0()
                toVC.view.frame.origin.x += toVC.view.frame.width
                gestures.transitionAnimatorBlock = {
                    self.shadeView.backgroundColor = UIColor.secondarySystemBackground
                    self.shadeView.alpha = 1
                    self.blurView.effect = UIBlurEffect(style: .light)
                    self.tabBarView.shadeView.alpha = 0
                    self.tabBarView.blurView.effect = UIBlurEffect(style: .light)
                    self.tabBarView.blurBackgroundView.alpha = 1
                }
                blurAnimator?.addAnimations {
                    self.gestures.transitionAnimatorBlock?()
                }
                camera.enableButtons(false)
            } else { /// photos to camera
                startCamera()
                tabBarView.getBlocks(from: fromVC, to: .camera).0()
                blurView.effect = UIBlurEffect(style: .light)
                gestures.transitionAnimatorBlock = {
                    self.shadeView.alpha = 0
                    self.blurView.effect = nil
                    self.tabBarView.shadeView.alpha = 1
                    self.tabBarView.blurView.effect = nil
                    self.tabBarView.blurBackgroundView.alpha = 0
                }
                blurAnimator?.addAnimations {
                    self.gestures.transitionAnimatorBlock?()
                }
                containerView.bringSubviewToFront(fromVC.view)
                containerView.sendSubviewToBack(toVC.view)
            }
        } else if direction == .right {
            if toOverlay { /// camera to photos
                tabBarView.getBlocks(from: fromVC, to: .photos).0()
                toVC.view.frame.origin.x -= toVC.view.frame.width
                
                gestures.transitionAnimatorBlock = {
                    self.shadeView.backgroundColor = UIColor.systemBackground
                    self.shadeView.alpha = 1
                    self.blurView.effect = UIBlurEffect(style: .light)
                    self.tabBarView.shadeView.alpha = 0
                    self.tabBarView.blurView.effect = UIBlurEffect(style: .light)
                    self.tabBarView.blurBackgroundView.alpha = 1
                }
                blurAnimator?.addAnimations {
                    self.gestures.transitionAnimatorBlock?()
                }
                camera.enableButtons(false)
            } else { /// lists to camera
                startCamera()
                tabBarView.getBlocks(from: fromVC, to: .camera).0()
                blurView.effect = UIBlurEffect(style: .light)
                gestures.transitionAnimatorBlock = {
                    self.shadeView.alpha = 0
                    self.blurView.effect = nil
                    self.tabBarView.shadeView.alpha = 1
                    self.tabBarView.blurView.effect = nil
                    self.tabBarView.blurBackgroundView.alpha = 0
                }
                blurAnimator?.addAnimations {
                    self.gestures.transitionAnimatorBlock?()
                }
                containerView.bringSubviewToFront(fromVC.view)
                containerView.sendSubviewToBack(toVC.view)
            }
        }
        
        gestures.toOverlay = toOverlay
        ViewControllerState.newVC = toVC
        blurAnimator?.startAnimation()
        blurAnimator?.pauseAnimation()
    }
    
    func continueMoveVC(totalValue: CGFloat) {
        var value: CGFloat = totalValue
        if gestures.direction == .left {
            let maxValue = min(containerView.frame.width, -min(0, totalValue))
            blurAnimator?.fractionComplete = min(1, maxValue / containerView.frame.width)
            if gestures.toOverlay { /// camera to lists
                tabBarView.makePercentageOfActive(percentage: max(0, 1 - (maxValue / containerView.frame.width)))
                tabBarView.cameraIcon.makePercentageOfActive(percentage: max(0, 1 - (maxValue / containerView.frame.width)))
                tabBarView.listsIcon.makePercentageOfActive(percentage: min(1, maxValue / containerView.frame.width), originalDetails: FindConstants.detailIconColorDark, originalForeground: FindConstants.foregroundIconColorDark, originalBackground: FindConstants.backgroundIconColorDark)
                tabBarView.photosIcon.makePercentageOfDark(percentage: max(0, 1 - (maxValue / containerView.frame.width)))
                /// overflow
                if totalValue <= -containerView.frame.width { /// totalValue is negative
                    let amountOver = totalValue + containerView.frame.width
                    value = -containerView.frame.width - pow(-amountOver, FindConstants.rubberBandingPower)
                }
                ViewControllerState.newVC?.view.frame.origin.x = containerView.frame.width + value /// value is negative
            } else { /// photos to camera
                tabBarView.makePercentageOfActive(percentage: maxValue / containerView.frame.width)
                tabBarView.photosIcon.makePercentageOfActive(percentage: 1 - (maxValue / containerView.frame.width), originalDetails: FindConstants.detailIconColorDark, originalForeground: FindConstants.foregroundIconColorDark, originalBackground: FindConstants.backgroundIconColorDark)
                tabBarView.cameraIcon.makePercentageOfActive(percentage: maxValue / containerView.frame.width)
                tabBarView.listsIcon.makePercentageOfDark(percentage: min(1, maxValue / containerView.frame.width))
                /// overflow
                if totalValue >= 0 {
                    value = pow(totalValue, FindConstants.rubberBandingPower)
                }
                ViewControllerState.currentVC?.view.frame.origin.x = value /// value is negative
            }
        } else if gestures.direction == .right {
            let maxValue = min(containerView.frame.width, max(0, totalValue))
            blurAnimator?.fractionComplete = min(1, maxValue / containerView.frame.width)
            if gestures.toOverlay { /// camera to photos
                tabBarView.makePercentageOfActive(percentage: max(0, 1 - (maxValue / containerView.frame.width)))
                tabBarView.cameraIcon.makePercentageOfActive(percentage: max(0, 1 - (maxValue / containerView.frame.width)))
                tabBarView.photosIcon.makePercentageOfActive(percentage: min(1, maxValue / containerView.frame.width), originalDetails: FindConstants.detailIconColorDark, originalForeground: FindConstants.foregroundIconColorDark, originalBackground: FindConstants.backgroundIconColorDark)
                tabBarView.listsIcon.makePercentageOfDark(percentage: max(0, 1 - (maxValue / containerView.frame.width)))
                /// overflow
                if totalValue >= containerView.frame.width {
                    let amountOver = totalValue - containerView.frame.width
                    value = containerView.frame.width + pow(amountOver, FindConstants.rubberBandingPower)
                }
                ViewControllerState.newVC?.view.frame.origin.x = -containerView.frame.width + value
            } else { /// lists to camera
                tabBarView.makePercentageOfActive(percentage: maxValue / containerView.frame.width)
                tabBarView.listsIcon.makePercentageOfActive(percentage: 1 - (maxValue / containerView.frame.width), originalDetails: FindConstants.detailIconColorDark, originalForeground: FindConstants.foregroundIconColorDark, originalBackground: FindConstants.backgroundIconColorDark)
                tabBarView.cameraIcon.makePercentageOfActive(percentage: maxValue / containerView.frame.width)
                tabBarView.photosIcon.makePercentageOfDark(percentage: min(1, maxValue / containerView.frame.width))
                if totalValue <= 0 {
                    value = -pow(-totalValue, FindConstants.rubberBandingPower)
                }
                ViewControllerState.currentVC?.view.frame.origin.x = value
            }
        }
    }
    
    func finishMoveVC(currentX: CGFloat, velocity: CGFloat, from fromVC: UIViewController, to toVC: UIViewController, instantly: Bool = false) {
        animator = nil
        
        let decelerationRate = UIScrollView.DecelerationRate.normal.rawValue
        
        let projectedPosition = currentX + project(initialVelocity: velocity, decelerationRate: decelerationRate)
        
        let centerX = containerView.frame.width / 2
        let finalX: CGFloat
        
        let favoredDirection: Direction
        
        if projectedPosition <= centerX {
            favoredDirection = .left
            finalX = 0
        } else {
            favoredDirection = .right
            finalX = containerView.frame.width
        }

        let relativeV = CGVector(
            dx: relativeVelocity(forVelocity: velocity, from: currentX, to: finalX),
            dy: 0
        )
        
        var block: (() -> Void) = {}
        var tabCompletion: (() -> Void) = {}
        
        var finishImmediately = false
        
        switch fromVC {
        case is PhotosWrapperController:
            switch toVC {
            case is PhotosWrapperController:
                break
            case is CameraViewController:
                if favoredDirection == .left { /// completed
                    let (prep, animations, completion) = tabBarView.getBlocks(from: fromVC, to: .camera)
                    prep()
                    tabBarView.animatingObjects += 1
                    tabBarView.cameraIcon.makeLayerActiveState(duration: FindConstants.transitionDuration)
                    tabBarView.makeLayerActiveState(duration: FindConstants.transitionDuration)
                    block = {
                        fromVC.view.frame.origin.x = -self.containerView.frame.width
                        animations?()
                    }
                    tabCompletion = completion
                    gestures.framePositionWhenLifted = fromVC.view.frame.origin.x
                    gestures.viewToTrackChanges = fromVC.view
                    
                    if currentX <= -FindConstants.gesturePadding {
                        finishImmediately = true
                    }
                    gestures.completedMove = true
                } else if favoredDirection == .right { /// cancelled
                    let (_, animations, completion) = tabBarView.getBlocks(from: toVC, to: .photos)
                    tabBarView.animatingObjects += 1
                    tabBarView.cameraIcon.makeLayerInactiveState(duration: FindConstants.transitionDuration)
                    tabBarView.makeLayerInactiveState(duration: FindConstants.transitionDuration)
                    block = {
                        fromVC.view.frame.origin.x = 0
                        animations?()
                    }
                    tabCompletion = completion
                    gestures.framePositionWhenLifted = fromVC.view.frame.origin.x
                    gestures.viewToTrackChanges = fromVC.view
                    gestures.completedMove = false
                    blurAnimator?.isReversed = true
                }
            case is ListsNavController:
                break
            default:
                break
            }
        case is CameraViewController:
            switch toVC {
            case is PhotosWrapperController:
                if favoredDirection == .right { /// completed
                    let (prep, animations, completion) = tabBarView.getBlocks(from: fromVC, to: .photos)
                    prep()
                    tabBarView.cameraIcon.makeLayerInactiveState(duration: FindConstants.transitionDuration)
                    tabBarView.makeLayerInactiveState(duration: FindConstants.transitionDuration)
                    tabBarView.animatingObjects += 1
                    block = {
                        toVC.view.frame.origin.x = 0
                        animations?()
                    }
                    tabCompletion = completion
                    gestures.framePositionWhenLifted = toVC.view.frame.origin.x
                    gestures.viewToTrackChanges = toVC.view
                    gestures.completedMove = true
                } else if favoredDirection == .left { /// canceled
                    let (_, animations, completion) = tabBarView.getBlocks(from: toVC, to: .camera)
                    tabBarView.animatingObjects += 1
                    tabBarView.cameraIcon.makeLayerActiveState(duration: FindConstants.transitionDuration)
                    tabBarView.makeLayerActiveState(duration: FindConstants.transitionDuration)
                    block = {
                        toVC.view.frame.origin.x = -self.containerView.frame.width
                        animations?()
                    }
                    tabCompletion = completion
                    if currentX < -FindConstants.gesturePadding {
                        finishImmediately = true
                    }
                    gestures.framePositionWhenLifted = toVC.view.frame.origin.x
                    gestures.viewToTrackChanges = toVC.view
                    gestures.completedMove = false
                    blurAnimator?.isReversed = true
                }
            case is CameraViewController:
                break
            case is ListsNavController:
                if favoredDirection == .left { /// completed
                    let (prep, animations, completion) = tabBarView.getBlocks(from: fromVC, to: .lists)
                    prep()
                    tabBarView.animatingObjects += 1
                    tabBarView.cameraIcon.makeLayerInactiveState(duration: FindConstants.transitionDuration)
                    tabBarView.makeLayerInactiveState(duration: FindConstants.transitionDuration)
                    block = {
                        toVC.view.frame.origin.x = 0
                        animations?()
                    }
                    tabCompletion = completion
                    gestures.framePositionWhenLifted = toVC.view.frame.origin.x
                    gestures.viewToTrackChanges = toVC.view
                    gestures.completedMove = true
                } else if favoredDirection == .right { /// cancelled
                    let (_, animations, completion) = tabBarView.getBlocks(from: toVC, to: .camera)
                    tabBarView.animatingObjects += 1
                    tabBarView.cameraIcon.makeLayerActiveState(duration: FindConstants.transitionDuration)
                    tabBarView.makeLayerActiveState(duration: FindConstants.transitionDuration)
                    block = {
                        toVC.view.frame.origin.x = self.containerView.frame.width
                        animations?()
                    }
                    if currentX > containerView.frame.width + FindConstants.gesturePadding {
                        finishImmediately = true
                    }
                    tabCompletion = completion
                    gestures.framePositionWhenLifted = toVC.view.frame.origin.x
                    gestures.viewToTrackChanges = toVC.view
                    gestures.completedMove = false
                    blurAnimator?.isReversed = true
                }
            default:
                break
            }
        case is ListsNavController:
            switch toVC {
            case is PhotosWrapperController:
                break
            case is CameraViewController:
                if favoredDirection == .right { /// completed
                    let (prep, animations, completion) = tabBarView.getBlocks(from: fromVC, to: .camera)
                    prep()
                    tabBarView.animatingObjects += 1
                    tabBarView.cameraIcon.makeLayerActiveState(duration: FindConstants.transitionDuration)
                    tabBarView.makeLayerActiveState(duration: FindConstants.transitionDuration)
                    block = {
                        fromVC.view.frame.origin.x = self.containerView.frame.width
                        animations?()
                    }
                    tabCompletion = completion
                    gestures.framePositionWhenLifted = fromVC.view.frame.origin.x
                    gestures.viewToTrackChanges = fromVC.view
                    
                    if currentX >= containerView.frame.width + FindConstants.gesturePadding {
                        finishImmediately = true
                    }
                    gestures.completedMove = true
                } else if favoredDirection == .left { /// cancelled
                    let (_, animations, completion) = tabBarView.getBlocks(from: toVC, to: .lists)
                    tabBarView.animatingObjects += 1
                    tabBarView.cameraIcon.makeLayerInactiveState(duration: FindConstants.transitionDuration)
                    tabBarView.makeLayerInactiveState(duration: FindConstants.transitionDuration)
                    block = {
                        fromVC.view.frame.origin.x = 0
                        animations?()
                    }
                    tabCompletion = completion
                    gestures.framePositionWhenLifted = fromVC.view.frame.origin.x
                    gestures.viewToTrackChanges = fromVC.view
                    gestures.completedMove = false
                    blurAnimator?.isReversed = true
                }
            case is ListsNavController:
                break
            default:
                break
            }
        default:
            break
        }
        
        let completion: (() -> Void) = {
            self.tabBarView.animatingObjects -= 1
            
            if self.tabBarView.animatingObjects == 0 || self.tabBarView.gestureInterruptedButton {
                tabCompletion()
            }
            
            if self.tabBarView.animatingObjects == 0 {
                self.tabBarView.gestureInterruptedButton = false
            }
            if self.gestures.completedMove {
                toVC.didMove(toParent: self)
                
                fromVC.willMove(toParent: nil)
                fromVC.view.removeFromSuperview()
                fromVC.removeFromParent()
                
                ViewControllerState.currentVC = ViewControllerState.newVC
                ViewControllerState.newVC = nil
                
                self.blurAnimator?.isReversed = false
                
            } else {
                toVC.willMove(toParent: nil)
                toVC.view.removeFromSuperview()
                toVC.removeFromParent()
                ViewControllerState.newVC = nil
            }
            if !(ViewControllerState.currentVC is CameraViewController) {
                self.tabBarView.showLineView(show: true)
            }
            self.gestures.direction = nil
            self.gestures.isAnimating = false
            self.gestures.totalTranslation = 0
            self.gestures.gestureSavedOffset = 0
            self.gestures.completedMove = false
            if let currentVC = ViewControllerState.currentVC {
                self.notifyCompletion(finishedAtVC: currentVC)
            }
        }
        if finishImmediately || instantly {
            block()
            completion()
            blurAnimator?.stopAnimation(false)
            blurAnimator?.finishAnimation(at: .start)
            shadeView.alpha = 0
            blurView.effect = nil
            
            if finishImmediately {
                tabBarView.shadeView.alpha = 1
                tabBarView.blurView.effect = nil
                tabBarView.blurBackgroundView.alpha = 0
            }
            if instantly {
                if toVC is CameraViewController {
                    tabBarView.shadeView.alpha = 1
                    tabBarView.blurView.effect = nil
                    tabBarView.blurBackgroundView.alpha = 0
                } else {
                    tabBarView.shadeView.alpha = 0
                    tabBarView.blurView.effect = UIBlurEffect(style: .light)
                    tabBarView.blurBackgroundView.alpha = 1
                }
            }
            
        } else {
            animator?.stopAnimation(true)
            let timingParameters = UISpringTimingParameters(damping: 1, response: FindConstants.transitionDuration, initialVelocity: relativeV)
            animator = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters)
            
            animator?.addAnimations(block)
            animator?.addCompletion { _ in
                completion()
            }
            gestures.isAnimating = true
            
            animator?.startAnimation()
            blurAnimator?.continueAnimation(withTimingParameters: timingParameters, durationFactor: 1)
        }
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
