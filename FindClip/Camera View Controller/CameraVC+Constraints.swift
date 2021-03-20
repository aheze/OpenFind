//
//  CameraVC+Constraints.swift
//  FindAppClip1
//
//  Created by Zheng on 3/13/21.
//

import UIKit

extension CameraViewController {
    func configureConstraints() {
        if Positions.deviceHasNotch {
            textContainerTopC.constant = 50
            promptLabelTopC.constant = 10
        } else {
            textContainerTopC.constant = 26
            promptLabelTopC.constant = 8
        }
        
        cameraControlsBottomC.constant = Positions.bottomStop + 16
        showControlsBottomC.constant = Positions.bottomStop + 4
        
        
        cameraMaskBottomC.constant = Positions.bottomStop
        cameraShadowBottomC.constant = Positions.bottomStop
        overlayShadowBottomC.constant = Positions.bottomStop
        
        bottomPromptViewHeight.constant = Positions.bottomStop
        goBackBottomC.constant = Positions.bottomStop
    }
    
    func makeFullScreen(_ fullScreen: Bool) {
        if fullScreen {
            textContainerTopC.constant = -textFieldContainer.bounds.height - 10
            cameraControlsBottomC.constant = -controlsContainer.bounds.height
            showControlsBottomC.constant = Positions.bottomStop + 16
        } else {
            textContainerTopC.constant = Positions.deviceHasNotch ? 50 : 26
            cameraControlsBottomC.constant = Positions.bottomStop + 16
            showControlsBottomC.constant = Positions.bottomStop + 4
        }
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveLinear) {
            self.view.layoutIfNeeded()
            self.showControlsView.alpha = fullScreen ? 1 : 0
            self.controlsContainer.alpha = fullScreen ? 0 : 1
        }
    }
}
