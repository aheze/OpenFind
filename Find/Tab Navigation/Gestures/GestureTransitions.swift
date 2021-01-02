//
//  GestureTransitions.swift
//  FindTabBar
//
//  Created by Zheng on 12/20/20.
//

import UIKit

extension ViewController {
    func moveRubberBand(totalValue: CGFloat) {
        if gestures.direction == .left { /// in Lists, hitting right edge
            let safeTotalValue = min(0, totalValue)
            let adjustedValue = -pow(-safeTotalValue, Constants.rubberBandingPower)
            ViewControllerState.currentVC?.view.frame.origin.x = adjustedValue
        } else if gestures.direction == .right { /// in Photos, hitting left edge
            
            let safeTotalValue = max(0, totalValue)
            let adjustedValue = pow(safeTotalValue, Constants.rubberBandingPower)
            ViewControllerState.currentVC?.view.frame.origin.x = adjustedValue
        }
    }
    
    func finishMoveRubberBand(totalValue: CGFloat, velocity: CGFloat) {
        
        let maximumTotalValue = min(abs(totalValue), 200)
        let adjustedValue = pow(maximumTotalValue, Constants.rubberBandingPower)
        
        gestures.framePositionWhenLifted = ViewControllerState.currentVC?.view.frame.origin.x ?? 0
        gestures.viewToTrackChanges = ViewControllerState.currentVC?.view
        gestures.isAnimating = true

        let decelerationRate = UIScrollView.DecelerationRate.normal.rawValue
        
        let projectedPosition = adjustedValue + project(initialVelocity: velocity, decelerationRate: decelerationRate)
        let relativeV = CGVector(
            dx: relativeVelocity(forVelocity: velocity, from: projectedPosition, to: 0),
            dy: 0
        )
        
        let timingParameters = UISpringTimingParameters(damping: 1, response: Constants.transitionDuration, initialVelocity: relativeV)
        animator = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters)
        animator?.addAnimations {
            ViewControllerState.currentVC?.view.frame.origin.x = 0
        }
        animator?.addCompletion({ _ in
            self.gestures.direction = nil
            self.gestures.isAnimating = false
            self.gestures.totalTranslation = 0
            self.gestures.isRubberBanding = false
            self.gestures.gestureSavedOffset = 0
        })
        animator?.startAnimation()
    }
    
    func startMoveVC(from fromVC: UIViewController, to toVC: UIViewController, direction: Direction, toOverlay: Bool = true) {
        print("start move view controller from \(fromVC), to \(toVC)")
        self.addChild(toVC)
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
                    self.shadeView.backgroundColor = UIColor.yellow
                    self.shadeView.alpha = 1
                    self.blurView.effect = UIBlurEffect(style: .light)
                    self.tabBarView.shadeView.alpha = 0
                    self.tabBarView.blurView.effect = UIBlurEffect(style: .light)
                }
                blurAnimator?.addAnimations {
                    self.gestures.transitionAnimatorBlock?()
                }
            } else { /// photos to camera
                tabBarView.getBlocks(from: fromVC, to: .camera).0()
                blurView.effect = UIBlurEffect(style: .light)
                gestures.transitionAnimatorBlock = {
                    self.shadeView.alpha = 0
                    self.blurView.effect = nil
                    self.tabBarView.shadeView.alpha = 1
                    self.tabBarView.blurView.effect = nil
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
                    self.shadeView.backgroundColor = UIColor.blue
                    self.shadeView.alpha = 1
                    self.blurView.effect = UIBlurEffect(style: .light)
                    self.tabBarView.shadeView.alpha = 0
                    self.tabBarView.blurView.effect = UIBlurEffect(style: .light)
                }
                blurAnimator?.addAnimations {
                    self.gestures.transitionAnimatorBlock?()
                }
            } else { /// lists to camera
                tabBarView.getBlocks(from: fromVC, to: .camera).0()
                blurView.effect = UIBlurEffect(style: .light)
                gestures.transitionAnimatorBlock = {
                    self.shadeView.alpha = 0
                    self.blurView.effect = nil
                    self.tabBarView.shadeView.alpha = 1
                    self.tabBarView.blurView.effect = nil
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
                tabBarView.listsIcon.makePercentageOfActive(percentage: min(1, maxValue / containerView.frame.width), originalDetails: Constants.detailIconColorDark, originalForeground: Constants.foregroundIconColorDark, originalBackground: Constants.backgroundIconColorDark)
                tabBarView.photosIcon.makePercentageOfDark(percentage: max(0, 1 - (maxValue / containerView.frame.width)))
                /// overflow
                if totalValue <= -containerView.frame.width { /// totalValue is negative
                    let amountOver = totalValue + containerView.frame.width
                    value = -containerView.frame.width - pow(-amountOver, Constants.rubberBandingPower)
                }
                ViewControllerState.newVC?.view.frame.origin.x = containerView.frame.width + value /// value is negative
            } else { /// photos to camera
                tabBarView.makePercentageOfActive(percentage: maxValue / containerView.frame.width)
                tabBarView.photosIcon.makePercentageOfActive(percentage: 1 - (maxValue / containerView.frame.width), originalDetails: Constants.detailIconColorDark, originalForeground: Constants.foregroundIconColorDark, originalBackground: Constants.backgroundIconColorDark)
                tabBarView.cameraIcon.makePercentageOfActive(percentage: maxValue / containerView.frame.width)
                tabBarView.listsIcon.makePercentageOfDark(percentage: min(1, maxValue / containerView.frame.width))
                /// overflow
                if totalValue >= 0 {
                    value = pow(totalValue, Constants.rubberBandingPower)
                }
                ViewControllerState.currentVC?.view.frame.origin.x = value /// value is negative
            }
        } else if gestures.direction == .right {
            let maxValue = min(containerView.frame.width, max(0, totalValue))
            blurAnimator?.fractionComplete = min(1, maxValue / containerView.frame.width)
            if gestures.toOverlay { /// camera to photos
                tabBarView.makePercentageOfActive(percentage: max(0, 1 - (maxValue / containerView.frame.width)))
                tabBarView.cameraIcon.makePercentageOfActive(percentage: max(0, 1 - (maxValue / containerView.frame.width)))
                tabBarView.photosIcon.makePercentageOfActive(percentage: min(1, maxValue / containerView.frame.width), originalDetails: Constants.detailIconColorDark, originalForeground: Constants.foregroundIconColorDark, originalBackground: Constants.backgroundIconColorDark)
                tabBarView.listsIcon.makePercentageOfDark(percentage: max(0, 1 - (maxValue / containerView.frame.width)))
                /// overflow
                if totalValue >= containerView.frame.width {
                    let amountOver = totalValue - containerView.frame.width
                    value = containerView.frame.width + pow(amountOver, Constants.rubberBandingPower)
                }
                ViewControllerState.newVC?.view.frame.origin.x = -containerView.frame.width + value
            } else { /// lists to camera
                tabBarView.makePercentageOfActive(percentage: maxValue / containerView.frame.width)
                tabBarView.listsIcon.makePercentageOfActive(percentage: 1 - (maxValue / containerView.frame.width), originalDetails: Constants.detailIconColorDark, originalForeground: Constants.foregroundIconColorDark, originalBackground: Constants.backgroundIconColorDark)
                tabBarView.cameraIcon.makePercentageOfActive(percentage: maxValue / containerView.frame.width)
                tabBarView.photosIcon.makePercentageOfDark(percentage: min(1, maxValue / containerView.frame.width))
                if totalValue <= 0 {
                    value = -pow(-totalValue, Constants.rubberBandingPower)
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
        case is PhotosNavController:
            switch toVC {
            case is PhotosNavController:
                print("ERROR! Is same")
            case is CameraViewController:
                if favoredDirection == .left { /// completed
                    let (prep, animations, completion) = tabBarView.getBlocks(from: fromVC, to: .camera)
                    prep()
                    tabBarView.animatingObjects += 1
                    tabBarView.cameraIcon.makeLayerActiveState(duration: Constants.transitionDuration)
                    tabBarView.makeLayerActiveState(duration: Constants.transitionDuration)
                    block = {
                        fromVC.view.frame.origin.x = -self.containerView.frame.width
                        animations?()
                    }
                    tabCompletion = completion
                    gestures.framePositionWhenLifted = fromVC.view.frame.origin.x
                    gestures.viewToTrackChanges = fromVC.view
                    
                    if currentX <= -Constants.gesturePadding {
                        finishImmediately = true
                    }
                    gestures.completedMove = true
                } else if favoredDirection == .right { /// cancelled
                    let (_, animations, completion) = tabBarView.getBlocks(from: toVC, to: .photos)
                    tabBarView.animatingObjects += 1
                    tabBarView.cameraIcon.makeLayerInactiveState(duration: Constants.transitionDuration)
                    tabBarView.makeLayerInactiveState(duration: Constants.transitionDuration)
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
                print("error! Should not swipe from photos to lists")
            default:
                print("Could not cast in finish vc - photos")
            }
        case is CameraViewController:
            switch toVC {
            case is PhotosNavController:
                if favoredDirection == .right { /// completed
                    let (prep, animations, completion) = tabBarView.getBlocks(from: fromVC, to: .photos)
                    prep()
                    tabBarView.cameraIcon.makeLayerInactiveState(duration: Constants.transitionDuration)
                    tabBarView.makeLayerInactiveState(duration: Constants.transitionDuration)
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
                    tabBarView.cameraIcon.makeLayerActiveState(duration: Constants.transitionDuration)
                    tabBarView.makeLayerActiveState(duration: Constants.transitionDuration)
                    block = {
                        toVC.view.frame.origin.x = -self.containerView.frame.width
                        animations?()
                    }
                    tabCompletion = completion
                    if currentX < -Constants.gesturePadding {
                        finishImmediately = true
                    }
                    gestures.framePositionWhenLifted = toVC.view.frame.origin.x
                    gestures.viewToTrackChanges = toVC.view
                    gestures.completedMove = false
                    blurAnimator?.isReversed = true
                }
            case is CameraViewController:
                print("ERROR! Is same")
            case is ListsNavController:
                if favoredDirection == .left { /// completed
                    let (prep, animations, completion) = tabBarView.getBlocks(from: fromVC, to: .lists)
                    prep()
                    tabBarView.animatingObjects += 1
                    tabBarView.cameraIcon.makeLayerInactiveState(duration: Constants.transitionDuration)
                    tabBarView.makeLayerInactiveState(duration: Constants.transitionDuration)
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
                    tabBarView.cameraIcon.makeLayerActiveState(duration: Constants.transitionDuration)
                    tabBarView.makeLayerActiveState(duration: Constants.transitionDuration)
                    block = {
                        toVC.view.frame.origin.x = self.containerView.frame.width
                        animations?()
                    }
                    if currentX > containerView.frame.width + Constants.gesturePadding {
                        finishImmediately = true
                    }
                    tabCompletion = completion
                    gestures.framePositionWhenLifted = toVC.view.frame.origin.x
                    gestures.viewToTrackChanges = toVC.view
                    gestures.completedMove = false
                    blurAnimator?.isReversed = true
                }
            default:
                print("Could not cast in finish vc - camera")
            }
        case is ListsNavController:
            switch toVC {
            case is PhotosNavController:
                print("error! Should not swipe from lists to photos")
            case is CameraViewController:
                if favoredDirection == .right { /// completed
                    let (prep, animations, completion) = tabBarView.getBlocks(from: fromVC, to: .camera)
                    prep()
                    tabBarView.animatingObjects += 1
                    tabBarView.cameraIcon.makeLayerActiveState(duration: Constants.transitionDuration)
                    tabBarView.makeLayerActiveState(duration: Constants.transitionDuration)
                    block = {
                        fromVC.view.frame.origin.x = self.containerView.frame.width
                        animations?()
                    }
                    tabCompletion = completion
                    gestures.framePositionWhenLifted = fromVC.view.frame.origin.x
                    gestures.viewToTrackChanges = fromVC.view
                    
                    if currentX >= containerView.frame.width + Constants.gesturePadding {
                        finishImmediately = true
                    }
                    gestures.completedMove = true
                } else if favoredDirection == .left { /// cancelled
                    let (_, animations, completion) = tabBarView.getBlocks(from: toVC, to: .lists)
                    tabBarView.animatingObjects += 1
                    tabBarView.cameraIcon.makeLayerInactiveState(duration: Constants.transitionDuration)
                    tabBarView.makeLayerInactiveState(duration: Constants.transitionDuration)
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
                print("ERROR! Is same")
            default:
                print("Could not cast in finish vc - lists")
            }
        default:
            print("Could not case in finish vc")
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
                ViewControllerState.newVC?.didMove(toParent: self)
                
                ViewControllerState.currentVC?.willMove(toParent: nil)
                ViewControllerState.currentVC?.view.removeFromSuperview()
                ViewControllerState.currentVC?.removeFromParent()
                
                ViewControllerState.currentVC = ViewControllerState.newVC
                ViewControllerState.newVC = nil
                
                self.blurAnimator?.isReversed = false
                
                print("Current view controller: \(ViewControllerState.currentVC)")
            } else {
                print("Did not complete move")
                ViewControllerState.newVC?.willMove(toParent: nil)
                ViewControllerState.newVC?.view.removeFromSuperview()
                ViewControllerState.newVC?.removeFromParent()
                ViewControllerState.newVC = nil
            }
            if ViewControllerState.currentVC is CameraViewController {
                self.tabBarView.showLineView(show: false)
            } else {
                self.tabBarView.showLineView(show: true)
            }
            self.gestures.direction = nil
            self.gestures.isAnimating = false
            self.gestures.totalTranslation = 0
            self.gestures.gestureSavedOffset = 0
            self.gestures.completedMove = false
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
            }
            if instantly {
                if toVC is CameraViewController {
                    tabBarView.shadeView.alpha = 1
                    tabBarView.blurView.effect = nil
                } else {
                    tabBarView.shadeView.alpha = 0
                    tabBarView.blurView.effect = UIBlurEffect(style: .light)
                }
            }
            
        } else {
            animator?.stopAnimation(true)
            let timingParameters = UISpringTimingParameters(damping: 1, response: Constants.transitionDuration, initialVelocity: relativeV)
            animator = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters)
            
            animator?.addAnimations(block)
            animator?.addCompletion({ (position) in
                completion()
            })
            gestures.isAnimating = true
            
            animator?.startAnimation()
            blurAnimator?.continueAnimation(withTimingParameters: timingParameters, durationFactor: 1)
        }
        print("Starting final animation...")
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
