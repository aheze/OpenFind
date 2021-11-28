//
//  VC+Sizing.swift
//  AR
//
//  Created by Zheng on 11/24/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension ViewController {
    func updateViewportSize() {
        DispatchQueue.main.async {
            guard let imageSize = self.imageSize else { return }
            let imageFitViewCenteredRect = self.calculateContentRect(imageSize: imageSize, containerSize: self.view.frame.size, aspectMode: .scaleAspectFit)
            self.imageFitViewRect = imageFitViewCenteredRect
            self.imageFitView.frame = imageFitViewCenteredRect
            self.resetAverageView()
        }
    }
    
    func resetAverageView() {
//        let center = getResetCenter()
//        self.averageView.center = center
        for existingSubview in imageFitView.subviews {
            existingSubview.removeFromSuperview()
        }
    }
    func getResetCenter() -> CGPoint {
        return CGPoint(x: imageFitViewRect.width / 2, y: imageFitViewRect.height / 2)
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

