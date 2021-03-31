//
//  CameraVC+FullScreen.swift
//  Find
//
//  Created by Zheng on 3/5/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension CameraViewController {
    func toggleFullScreen(_ fullScreen: Bool) {
        if fullScreen {
            contentTopC.constant = -searchContentView.bounds.height - view.safeAreaInsets.top
            passthroughBottomC.constant = -passthroughGroupView.bounds.height - view.safeAreaInsets.bottom
            controlsBlurBottomC.constant = CGFloat(ConstantVars.tabHeight) - 30
            
            messageViewBottomC.constant = controlsBlurView.bounds.height + controlsBlurBottomC.constant + view.safeAreaInsets.bottom
            
            view.accessibilityElements = [cameraGroupView, showControlsButton]
        } else {
            contentTopC.constant = normalSearchFieldTopCConstant
            passthroughBottomC.constant = 0
            controlsBlurBottomC.constant = -controlsBlurView.bounds.height
            messageViewBottomC.constant = 0
            
            view.accessibilityElements = [topGroupView, warningView, alternateWarningView, whatsNewView, cameraGroupView, passthroughGroupView]
        }
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveLinear) {
            self.view.layoutIfNeeded()
            self.controlsBlurView.transform = fullScreen ? CGAffineTransform.identity : CGAffineTransform(scaleX: 0.7, y: 0.7)
            self.controlsBlurView.effect = fullScreen ? UIBlurEffect(style: .dark) : nil
            self.showControlsButton.alpha = fullScreen ? 1 : 0
            
            self.promptContainerView.alpha = fullScreen ? 0 : 1
            
        } completion: { _ in
            UIAccessibility.post(notification: .layoutChanged, argument: fullScreen ? self.showControlsButton : self.fullScreenView)
        }
        
        if !CameraState.isPaused {
            self.cameraChanged?(fullScreen, false)
        }
    }
    func adjustButtonLayout(_ paused: Bool, animate: Bool = true) {
        if paused {
            fullScreenLeftNeighborC.isActive = false
            fullScreenLeftC.isActive = true
            fullScreenBottomC.isActive = false
            fullScreenTopC.isActive = true
            
            flashRightNeighborC.isActive = false
            flashRightC.isActive = true
            flashBottomC.isActive = false
            flashTopC.isActive = true
            
            fullScreenLeftC.constant = 8
            flashRightC.constant = 8
            
            fullScreenTopC.constant = 8
            flashTopC.constant = 8
        } else {
            fullScreenLeftNeighborC.isActive = true
            fullScreenLeftC.isActive = false
            fullScreenBottomC.isActive = true
            fullScreenTopC.isActive = false
            
            flashRightNeighborC.isActive = true
            flashRightC.isActive = false
            flashBottomC.isActive = true
            flashTopC.isActive = false
        }
        
        if animate {
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveLinear) {
                self.view.layoutIfNeeded()
            }
        } else {
            self.view.layoutIfNeeded()
        }
    }
}
