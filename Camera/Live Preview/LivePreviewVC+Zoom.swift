//
//  LivePreviewVC+Zoom.swift
//  Camera
//
//  Created by Zheng on 11/23/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import AVFoundation

extension LivePreviewViewController {
    func changeZoom(to zoom: CGFloat, animated: Bool) {
        guard let cameraDevice = cameraDevice else { return }
        do {
            try cameraDevice.lockForConfiguration()
            if animated {
                cameraDevice.ramp(toVideoZoomFactor: zoom, withRate: 200)
            } else {
                cameraDevice.videoZoomFactor = zoom
            }
            cameraDevice.unlockForConfiguration()
        } catch {
            print("Error focusing \(error)")
        }
    }
    
    func changeAspectProgress(to aspectProgress: CGFloat) {
        print("aspect prog")
        
        let extraProgress = aspectProgressTarget - 1
        let scale = 1 + (extraProgress * aspectProgress)
        let previouslyHitAspectTarget = hitAspectTarget
        hitAspectTarget = scale >= aspectProgressTarget
        
        self.previewFitViewScale = CGAffineTransform(scaleX: scale, y: scale)
        
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

        self.testingView2.frame = previewFitViewFrame
        
        UIView.animate(withDuration: 0.3) {
            self.previewFitView.transform = self.previewFitViewScale
        }
        
        self.previewFitViewFrame = previewFitViewFrame
        
        if !Debug.tabBarAlwaysTransparent {
            if previouslyHitAspectTarget != hitAspectTarget {
                UIView.animate(withDuration: 0.6) {
                    self.safeViewContainer.backgroundColor = self.hitAspectTarget ? .blue : .clear
                }
            }
        }
    }
}

//        print("Frame: \(previewFitViewFrame)")
//        print("ap: \(imageFillSafeRect.applying(transform))")
//        previewFitViewFrame.setAsConstraints(
//            left: previewFitViewLeftC,
//            top: previewFitViewTopC,
//            width: previewFitViewWidthC,
//            height: previewFitViewHeightC
//        )
//
        
