//
//  LivePreviewVC+Resize.swift
//  Find
//
//  Created by Zheng on 11/22/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension LivePreviewViewController {
    func updateViewportSize(safeViewFrame: CGRect) {
//        print("up////")
        guard let imageSize = imageSize else { return }
        self.safeViewFrame = safeViewFrame
        
        let updatedSafeViewFrame = updatedSafeViewSize(aspectFill: hitAspectTarget)
        updatedSafeViewFrame.setAsConstraints(
            left: safeViewLeftC,
            top: safeViewTopC,
            width: safeViewWidthC,
            height: safeViewHeightC
        )
        
        let imageFitViewCenteredRect = calculateContentRect(imageSize: imageSize, containerSize: view.frame.size, aspectMode: .scaleAspectFit)
        let imageFillSafeCenteredRect = calculateContentRect(imageSize: imageFitViewCenteredRect.size, containerSize: safeViewFrame.size, aspectMode: .scaleAspectFill)
        
        /// only care about the fill rect - fills the safe area, with gap on left and right
        var imageFillSafeRect = imageFillSafeCenteredRect
        imageFillSafeRect.origin.y = safeViewFrame.origin.y
        
        self.imageFitViewSize = imageFitViewCenteredRect.size
        self.imageFillSafeRect = imageFillSafeRect
        
        
        previewFitView.bounds = CGRect(x: 0, y: 0, width: imageFillSafeRect.width, height: imageFillSafeRect.height)
        previewFitView.center = CGPoint(x: imageFillSafeRect.midX, y: imageFillSafeRect.midY)

        updateAspectProgressTarget()
    }
    
    /// updates and returns the frame of the safe view
    func updatedSafeViewSize(aspectFill: Bool) -> CGRect {
        let safeViewFrame: CGRect
        if aspectFill {
            safeViewFrame = CGRect(
                x: self.safeViewFrame.origin.x,
                y: self.view.frame.origin.y,
                width: self.safeViewFrame.width,
                height: self.view.frame.height
            )
        } else {
            safeViewFrame = self.safeViewFrame
        }
        return safeViewFrame
    }
    
    func updateAspectProgressTarget() {
        
        let halfImageHeight = self.imageFillSafeRect.height / 2
        
        let containerTopHalfHeight = self.imageFillSafeRect.midY
        let containerBottomHalfHeight = view.bounds.height - containerTopHalfHeight
        
        /// calculate the image's progress to the full view for both top and bottom
        let imageTopMultiplier = containerTopHalfHeight / halfImageHeight
        let imageBottomMultiplier = containerBottomHalfHeight / halfImageHeight
        let imageMultiplier = max(imageTopMultiplier, imageBottomMultiplier)
        
        
        aspectProgressTarget = imageMultiplier
    }
    
    func calculateContentRect(imageSize: CGSize, containerSize: CGSize, aspectMode: UIView.ContentMode) -> CGRect {
        var contentRect = CGRect.zero
        
        let imageAspect = imageSize.height / imageSize.width
        let containerAspect = containerSize.height / containerSize.width
        if /// match width
            (imageAspect > containerAspect) && (aspectMode == .scaleAspectFill) || /// image extends top and bottom
            (imageAspect <= containerAspect) && (aspectMode == .scaleAspectFit) /// image has gap top and bottom
        {
            let newImageHeight = containerSize.width * imageAspect
            let newY = -(newImageHeight - containerSize.height) / 2
            contentRect = CGRect(x: 0, y: newY, width: containerSize.width, height: newImageHeight)
            
        } else if /// match height
            (imageAspect < containerAspect) && (aspectMode == .scaleAspectFill) || /// image extends left and right
            (imageAspect >= containerAspect) && (aspectMode == .scaleAspectFit) /// image has gaps left and right
        {
            
            let newImageWidth = containerSize.height * (1 / imageAspect) /// the width of the overflowing image
            let newX = -(newImageWidth - containerSize.width) / 2
            contentRect = CGRect(x: newX, y: 0, width: newImageWidth, height: containerSize.height)
        }
        
        return contentRect
    }
}
