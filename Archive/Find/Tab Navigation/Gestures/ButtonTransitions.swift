//
//  ButtonTransitions.swift
//  FindTabBar
//
//  Created by Zheng on 12/20/20.
//

import UIKit

extension ViewController {
    func transition(to toVC: UIViewController) {
        /// gesture had started
        if let originalToVC = ViewControllerState.newVC {
            /// finish quickly
            if originalToVC >!< toVC {
                if !gestures.isAnimating {
                    let position: CGFloat
                    
                    gestures.totalTranslation = gestures.gestureSavedOffset
                    if gestures.direction == .left {
                        position = 0
                    } else {
                        position = containerView.frame.width
                    }
                    blurAnimator?.pauseAnimation()
                    if let currentVC = ViewControllerState.currentVC {
                        finishMoveVC(currentX: position, velocity: 0, from: currentVC, to: originalToVC, instantly: true)
                    }
                    
                    panGestureRecognizer.isEnabled = false
                    panGestureRecognizer.isEnabled = true
                    panGestureRecognizer.setTranslation(.zero, in: containerView)
                }
                
                /// instant switch (pressed icon other than gesture's 2)
            } else if let currentVC = ViewControllerState.currentVC {
                addChild(toVC, in: containerView)
                removeChild(currentVC)
                removeChild(originalToVC)
                ViewControllerState.currentVC = toVC
                ViewControllerState.newVC = nil
                
                panGestureRecognizer.isEnabled = false
                panGestureRecognizer.isEnabled = true
                panGestureRecognizer.setTranslation(.zero, in: containerView)
                gestures.completedMove = false
                gestures.direction = nil
                gestures.isAnimating = false
                gestures.totalTranslation = 0
                gestures.gestureSavedOffset = 0
                animator?.stopAnimation(true)
                blurAnimator?.stopAnimation(true)
                
                switch toVC {
                case is PhotosWrapperController:
                    tabBarView.hideRealShutter?(true)
                    tabBarView.cameraContainerView.alpha = 1
                    let block = {
                        self.tabBarView.cameraIcon.makeNormalState()()
                        self.tabBarView.listsIcon.makeNormalState(details: FindConstants.detailIconColorLight, foreground: FindConstants.foregroundIconColorLight, background: FindConstants.backgroundIconColorLight)()
                        self.tabBarView.photosIcon.makeActiveState()()
                    }
                    tabBarView.cameraIcon.makeLayerInactiveState(duration: FindConstants.transitionDuration)
                    tabBarView.makeLayerInactiveState(duration: FindConstants.transitionDuration)
                    
                    let completion = {}
                    
                    shadeView.backgroundColor = UIColor.systemBackground
                    shadeView.alpha = 1
                    blurView.effect = UIBlurEffect(style: .light)
                    tabBarView.shadeView.alpha = 0
                    tabBarView.blurView.effect = UIBlurEffect(style: .light)
                    tabBarView.blurBackgroundView.alpha = 1
                    containerView.bringSubviewToFront(toVC.view)
                    containerView.sendSubviewToBack(camera.view)
                    
                    tabBarView.animate(block: block, completion: completion)
                    
                case is CameraViewController:
                    tabBarView.hideRealShutter?(true)
                    let block = {
                        self.tabBarView.photosIcon.makeNormalState(details: FindConstants.detailIconColorDark, foreground: FindConstants.foregroundIconColorDark, background: FindConstants.backgroundIconColorDark)()
                        self.tabBarView.listsIcon.makeNormalState(details: FindConstants.detailIconColorDark, foreground: FindConstants.foregroundIconColorDark, background: FindConstants.backgroundIconColorDark)()
                        self.tabBarView.cameraIcon.makeActiveState()()
                    }
                    tabBarView.cameraIcon.makeLayerActiveState(duration: FindConstants.transitionDuration)
                    tabBarView.makeLayerActiveState(duration: FindConstants.transitionDuration)
                    
                    let completion: (() -> Void) = {
                        self.tabBarView.hideRealShutter?(false)
                        self.tabBarView.cameraContainerView.alpha = 0
                    }
                    
                    shadeView.alpha = 0
                    blurView.effect = nil
                    tabBarView.shadeView.alpha = 1
                    tabBarView.blurView.effect = nil
                    tabBarView.blurBackgroundView.alpha = 0
                    containerView.sendSubviewToBack(toVC.view) /// camera view
                    containerView.bringSubviewToFront(blurContainerView)
                    
                    tabBarView.animate(block: block, completion: completion)
                    
                case is ListsNavController:
                    tabBarView.hideRealShutter?(true)
                    tabBarView.cameraContainerView.alpha = 1
                    let block = {
                        self.tabBarView.photosIcon.makeNormalState(details: FindConstants.detailIconColorLight, foreground: FindConstants.foregroundIconColorLight, background: FindConstants.backgroundIconColorLight)()
                        self.tabBarView.cameraIcon.makeNormalState()()
                        self.tabBarView.listsIcon.makeActiveState()()
                    }
                    tabBarView.cameraIcon.makeLayerInactiveState(duration: FindConstants.transitionDuration)
                    tabBarView.makeLayerInactiveState(duration: FindConstants.transitionDuration)
                    
                    let completion = {}
                    
                    shadeView.backgroundColor = UIColor.secondarySystemBackground
                    shadeView.alpha = 1
                    blurView.effect = UIBlurEffect(style: .light)
                    tabBarView.shadeView.alpha = 0
                    tabBarView.blurView.effect = UIBlurEffect(style: .light)
                    tabBarView.blurBackgroundView.alpha = 1
                    containerView.bringSubviewToFront(blurContainerView)
                    containerView.bringSubviewToFront(toVC.view)
                    containerView.sendSubviewToBack(camera.view)
                    
                    tabBarView.animate(block: block, completion: completion)
                    
                default:
                    break
                }
                
                notifyCompletion(finishedAtVC: toVC, animatedToCamera: false)
            }
            
        } else { /// normal button press
            if let currentVC = ViewControllerState.currentVC {
                if gestures.isRubberBanding {
                    panGestureRecognizer.isEnabled = false
                    panGestureRecognizer.isEnabled = true
                    panGestureRecognizer.setTranslation(.zero, in: containerView)
                    gestures.direction = nil
                    gestures.isAnimating = false
                    gestures.totalTranslation = 0
                    gestures.isRubberBanding = false
                    gestures.gestureSavedOffset = 0
                }
                
                addChild(toVC, in: containerView)
                removeChild(currentVC)
                ViewControllerState.currentVC = toVC
                ViewControllerState.newVC = nil
                
                switch toVC {
                case is PhotosWrapperController:
                    containerView.bringSubviewToFront(toVC.view)
                    blurView.effect = UIBlurEffect(style: .light)
                    shadeView.alpha = 1
                    shadeView.backgroundColor = UIColor.systemBackground
                    tabBarView.shadeView.alpha = 0
                    tabBarView.blurView.effect = UIBlurEffect(style: .light)
                    tabBarView.blurBackgroundView.alpha = 1
                case is CameraViewController:
                    containerView.sendSubviewToBack(toVC.view)
                    blurView.effect = nil
                    shadeView.alpha = 0
                    tabBarView.shadeView.alpha = 1
                    tabBarView.blurView.effect = nil
                    tabBarView.blurBackgroundView.alpha = 0
                case is ListsNavController:
                    containerView.bringSubviewToFront(toVC.view)
                    blurView.effect = UIBlurEffect(style: .light)
                    shadeView.alpha = 1
                    shadeView.backgroundColor = UIColor.secondarySystemBackground
                    tabBarView.shadeView.alpha = 0
                    tabBarView.blurView.effect = UIBlurEffect(style: .light)
                    tabBarView.blurBackgroundView.alpha = 1
                default:
                    break
                }
                
                notifyCompletion(finishedAtVC: toVC, animatedToCamera: false)
            }
        }
    }
}
