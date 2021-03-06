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
            passthroughBottomC.constant = -passthroughView.bounds.height - CGFloat(view.safeAreaInsets.bottom)
            controlsBlurBottomC.constant = CGFloat(ConstantVars.tabHeight) - 30
            
            messageViewBottomC.constant = controlsBlurView.bounds.height + controlsBlurBottomC.constant
        } else {
            contentTopC.constant = normalSearchFieldTopCConstant
            passthroughBottomC.constant = 0
            controlsBlurBottomC.constant = -controlsBlurView.bounds.height
            messageViewBottomC.constant = 0
        }
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveLinear) {
            self.view.layoutIfNeeded()
            self.controlsBlurView.transform = fullScreen ? CGAffineTransform.identity : CGAffineTransform(scaleX: 0.7, y: 0.7)
            self.controlsBlurView.effect = fullScreen ? UIBlurEffect(style: .dark) : nil
            self.showControlsButton.alpha = fullScreen ? 1 : 0
        }
        
        if !CameraState.isPaused {
            self.cameraChanged?(fullScreen, false)
        }
    }
}
