//
//  VC+CameraSetup.swift
//  FindAppClip1
//
//  Created by Zheng on 3/12/21.
//

import UIKit

extension ViewController {
    func setupCameraView() {
        addChildViewController(cameraViewController, in: cameraReferenceView)
        
        cameraViewController.presentPressed = { [weak self] in
            if CurrentState.currentlyPresenting {
                UIView.animate(withDuration: 0.2) {
                    self?.cameraViewController.controlsBaseView.alpha = 1
                }

                self?.cameraViewController.startLivePreview()
                
                if CurrentState.presentingOverlay {
                    self?.dismissOverlay()
                }
            } else {
                if !CurrentState.presentingOverlay {
                    self?.displayOverlay()
                }
            }
            self?.blurCamera()
            self?.releasedPan(at: CurrentState.currentlyPresenting ? 0 : -(self?.view.bounds.height ?? 0), velocity: 0)
        }
        
        cameraReferenceView.clipsToBounds = false
        cameraViewController.view.clipsToBounds = false
    }
}
