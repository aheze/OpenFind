//
//  LivePreviewVC+Zoom.swift
//  Camera
//
//  Created by Zheng on 11/23/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import AVFoundation
import UIKit

/**
 Zoom + aspect progress changing
 */
extension LivePreviewViewController {
    func changeZoom(to zoom: CGFloat, animated: Bool) {
        
        guard let cameraDevice = cameraDevice else { return }
        do {
            try cameraDevice.lockForConfiguration()
            if animated {
                cameraDevice.ramp(toVideoZoomFactor: zoom, withRate: 100)
            } else {
                cameraDevice.videoZoomFactor = zoom
            }
            cameraDevice.unlockForConfiguration()
        } catch {}
    }
    
    func changeAspectProgress(to aspectProgress: CGFloat, animated: Bool) {
        let extraProgress = aspectProgressTarget - 1
        let scale = 1 + (extraProgress * aspectProgress)
        let previouslyHitAspectTarget = hitAspectTarget
        hitAspectTarget = scale >= aspectProgressTarget
        
        let safeViewFrame = updatedSafeViewSize(aspectFill: hitAspectTarget)
        safeViewFrame.setAsConstraints(
            left: safeViewLeftC,
            top: safeViewTopC,
            width: safeViewWidthC,
            height: safeViewHeightC
        )
        
        previewFitViewScale = CGAffineTransform(scaleX: scale, y: scale)
        
        /// recalculate preview fit frame
        let scaledWidth = imageFillSafeRect.width * scale
        let scaledHeight = imageFillSafeRect.height * scale
        
        let scaledOriginXDifference = (scaledWidth - imageFillSafeRect.width) / 2
        let scaledOriginYDifference = (scaledHeight - imageFillSafeRect.height) / 2
        let scaledOriginX = imageFillSafeRect.origin.x - scaledOriginXDifference
        let scaledOriginY = imageFillSafeRect.origin.y - scaledOriginYDifference
        
        let previewFitViewFrame = CGRect(
            x: scaledOriginX,
            y: scaledOriginY,
            width: scaledWidth,
            height: scaledHeight
        )
        self.previewFitViewFrame = previewFitViewFrame
        
        let safeViewOriginXFromPreviewFit = safeViewFrame.origin.x - previewFitViewFrame.origin.x
        let safeViewOriginYFromPreviewFit = safeViewFrame.origin.y - previewFitViewFrame.origin.y
        let safeViewFrameFromPreviewFit = CGRect(
            x: safeViewOriginXFromPreviewFit,
            y: safeViewOriginYFromPreviewFit,
            width: safeViewFrame.width,
            height: safeViewFrame.height
        )
        self.safeViewFrameFromPreviewFit = safeViewFrameFromPreviewFit
        
        changeContentContainerViewFrame?(previewFitViewFrame)
        changeSimulatedSafeViewFrame?(safeViewFrameFromPreviewFit)
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.previewFitView.transform = self.previewFitViewScale
            }
        } else {
            previewFitView.transform = previewFitViewScale
        }
        
        if !Debug.tabBarAlwaysTransparent {
            if previouslyHitAspectTarget != hitAspectTarget {
                UIView.animate(withDuration: 0.6) {
                    if self.hitAspectTarget {
                        self.safeViewContainer.backgroundColor = .black
                    } else {
                        self.safeViewContainer.backgroundColor = .clear
                    }
                }
            }
        }
    }
}
