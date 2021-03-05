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
            contentTopC.constant = -100
            passthroughBottomC.constant = -120
            controlsBlurBottomC.constant = CGFloat(ConstantVars.tabHeight) - 20
        } else {
            contentTopC.constant = normalSearchFieldTopCConstant
            passthroughBottomC.constant = 0
            controlsBlurBottomC.constant = -50
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
