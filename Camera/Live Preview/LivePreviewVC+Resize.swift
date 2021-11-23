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
        guard let imageSize = imageSize else { return }
        let imageAspect = imageSize.height / imageSize.width
        
        let imageFitViewRect = calculateContentRect(imageSize: imageSize, containerSize: view.frame.size, aspectMode: .scaleAspectFit)
        let imageFillSafeRect = calculateContentRect(imageSize: imageFitViewRect.size, containerSize: safeViewFrame.size, aspectMode: .scaleAspectFill)
        
//        print("Fit view: \(imageFitViewRect), fill safe: \(imageFillSafeRect)")
        
        let scaleHeightFactor = imageFillSafeRect.height / imageFitViewRect.height
//        let scale =
        
//        let contentFitAspect = contentFitRect.height / contentFitRect.width
//        let scaleFactor = contentFitAspect / imageAspect
        
        let safeViewYOffset = safeViewFrame.midY - view.frame.midY
        livePreviewView.transform = .identity
        livePreviewView.transform = CGAffineTransform(scaleX: scaleHeightFactor, y: scaleHeightFactor).translatedBy(x: 0, y: safeViewYOffset)
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
            let newImageWidth = containerSize.height * imageAspect /// the width of the overflowing image
            let newX = -(newImageWidth - containerSize.width) / 2
            contentRect = CGRect(x: newX, y: 0, width: newImageWidth, height: containerSize.height)
        }
        
        return contentRect
    }
}
