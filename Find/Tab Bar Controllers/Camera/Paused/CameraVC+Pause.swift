//
//  CameraVC+Pause.swift
//  Find
//
//  Created by Zheng on 1/24/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension CameraViewController {
    func pauseLivePreview() {
        cameraView.videoPreviewLayer.connection?.isEnabled = false
        capturePhoto { image in
            self.currentPausedImage = image
            self.showImageView(true)
        }
    }
    func startLivePreview() {
        cameraView.videoPreviewLayer.connection?.isEnabled = true
        self.showImageView(false)
    }
    
    func showImageView(_ show: Bool) {
        if show {
            pausedImageView.image = currentPausedImage
            UIView.animate(withDuration: 0.2) {
                self.pausedImageView.alpha = 1
            }

        } else {
            UIView.animate(withDuration: 0.1) {
                self.pausedImageView.alpha = 0
            }
        }
    }
    
    func removeFocusRects(_ remove: Bool) {
        focusView.isUserInteractionEnabled = !remove
        
        if remove {
            UIView.animate(withDuration: 0.2) {
                for existingFocusView in self.focusView.subviews {
                    existingFocusView.alpha = 0
                    existingFocusView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                }
            } completion: { _ in
                for existingFocusView in self.focusView.subviews {
                    existingFocusView.removeFromSuperview()
                }
            }
        }
    }
    
    func adjustButtonLayout(_ paused: Bool) {
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
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveLinear) {
            self.view.layoutIfNeeded()
        }
    }
}
