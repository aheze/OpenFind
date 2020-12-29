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
            if (originalToVC >!< toVC) {
                print("had original to. is same: \((originalToVC >!< toVC))")
                if !gestures.isAnimating {
                    print("currntly noy animatin")
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
                
                ///instant switch (pressed icon other than gesture's 2)
            } else if let currentVC = ViewControllerState.currentVC {
                addChild(toVC, in: containerView)
                removeChild(currentVC)
                removeChild(originalToVC)
                ViewControllerState.currentVC = toVC
                ViewControllerState.newVC = nil
                
                print("Stop+++++++++++++=")
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
                case is NewHistoryViewController:
                    tabBarView.hideRealShutter?(true)
                    tabBarView.cameraIcon.alpha = 1
                    let block = {
                        self.tabBarView.cameraIcon.makeNormalState()()
                        self.tabBarView.listsIcon.makeNormalState(details: Constants.detailIconColorLight, foreground: Constants.foregroundIconColorLight, background: Constants.backgroundIconColorLight)()
                        self.tabBarView.photosIcon.makeActiveState()()
                    }
                    self.tabBarView.cameraIcon.makeLayerInactiveState(duration: Constants.transitionDuration)
                    self.tabBarView.makeLayerInactiveState(duration: Constants.transitionDuration)
                    
                    let completion: (() -> Void) = {
//                        self.tabBarView.hideRealShutter?(true)
//                        self.tabBarView.cameraIcon.alpha = 1
                    }
                    
                    shadeView.backgroundColor = UIColor.blue
                    shadeView.alpha = 1
                    blurView.effect = UIBlurEffect(style: .light)
                    tabBarView.shadeView.alpha = 0
                    tabBarView.blurView.effect = UIBlurEffect(style: .light)
                    containerView.bringSubviewToFront(toVC.view)
                    containerView.sendSubviewToBack(camera.view)
                    
                    tabBarView.animate(block: block, completion: completion)
                    
                case is CameraViewController:
                    tabBarView.hideRealShutter?(true)
                    let block = {
                        self.tabBarView.photosIcon.makeNormalState(details: Constants.detailIconColorDark, foreground: Constants.foregroundIconColorDark, background: Constants.backgroundIconColorDark)()
                        self.tabBarView.listsIcon.makeNormalState(details: Constants.detailIconColorDark, foreground: Constants.foregroundIconColorDark, background: Constants.backgroundIconColorDark)()
                        self.tabBarView.cameraIcon.makeActiveState()()
                    }
                    self.tabBarView.cameraIcon.makeLayerActiveState(duration: Constants.transitionDuration)
                    self.tabBarView.makeLayerActiveState(duration: Constants.transitionDuration)
                    
                    let completion: (() -> Void) = {
                        self.tabBarView.hideRealShutter?(false)
                        self.tabBarView.cameraIcon.alpha = 0
                    }
                    
                    self.shadeView.alpha = 0
                    self.blurView.effect = nil
                    tabBarView.shadeView.alpha = 1
                    tabBarView.blurView.effect = nil
                    containerView.sendSubviewToBack(toVC.view) /// camera view
                    containerView.bringSubviewToFront(blurContainerView)
                    
                    tabBarView.animate(block: block, completion: completion)
                    
                case is ListsNavController:
                    tabBarView.hideRealShutter?(true)
                    tabBarView.cameraIcon.alpha = 1
                    let block = {
                        self.tabBarView.photosIcon.makeNormalState(details: Constants.detailIconColorLight, foreground: Constants.foregroundIconColorLight, background: Constants.backgroundIconColorLight)()
                        self.tabBarView.cameraIcon.makeNormalState()()
                        self.tabBarView.listsIcon.makeActiveState()()
                    }
                    self.tabBarView.cameraIcon.makeLayerInactiveState(duration: Constants.transitionDuration)
                    self.tabBarView.makeLayerInactiveState(duration: Constants.transitionDuration)
                    
                    let completion: (() -> Void) = {
//                        self.tabBarView.hideRealShutter?(true)
//                        self.tabBarView.cameraIcon.alpha = 1
                    }
                    
                    shadeView.backgroundColor = UIColor.yellow
                    shadeView.alpha = 1
                    blurView.effect = UIBlurEffect(style: .light)
                    tabBarView.shadeView.alpha = 0
                    tabBarView.blurView.effect = UIBlurEffect(style: .light)
                    containerView.bringSubviewToFront(blurContainerView)
                    containerView.bringSubviewToFront(toVC.view)
                    containerView.sendSubviewToBack(camera.view)
                    
                    tabBarView.animate(block: block, completion: completion)
                    
                default:
                    print("default trans")
                }
            }
            
        } else { /// normal button press
            if let currentVC = ViewControllerState.currentVC {
                if gestures.isRubberBanding {
                    print("rubber banding")
                    panGestureRecognizer.isEnabled = false
                    panGestureRecognizer.isEnabled = true
                    panGestureRecognizer.setTranslation(.zero, in: containerView)
                    self.gestures.direction = nil
                    self.gestures.isAnimating = false
                    self.gestures.totalTranslation = 0
                    self.gestures.isRubberBanding = false
                    self.gestures.gestureSavedOffset = 0
                }
                print("current exists")
                addChild(toVC, in: containerView)
                removeChild(currentVC)
                ViewControllerState.currentVC = toVC
                ViewControllerState.newVC = nil
                
                switch toVC {
                case is NewHistoryViewController:
                    containerView.bringSubviewToFront(toVC.view)
                    blurView.effect = UIBlurEffect(style: .light)
                    shadeView.alpha = 1
                    shadeView.backgroundColor = UIColor.blue
                    tabBarView.shadeView.alpha = 0
                    tabBarView.blurView.effect = UIBlurEffect(style: .light)
                    print("phots")
                case is CameraViewController:
                    print("camera")
                    containerView.sendSubviewToBack(toVC.view)
                    blurView.effect = nil
                    shadeView.alpha = 0
                    tabBarView.shadeView.alpha = 1
                    tabBarView.blurView.effect = nil
                case is ListsNavController:
                    containerView.bringSubviewToFront(toVC.view)
                    blurView.effect = UIBlurEffect(style: .light)
                    shadeView.alpha = 1
                    shadeView.backgroundColor = UIColor.yellow
                    tabBarView.shadeView.alpha = 0
                    tabBarView.blurView.effect = UIBlurEffect(style: .light)
                    print("listsss")
                default:
                    print("Could not cast transition vc")
                }
            }
        }
    }
}
