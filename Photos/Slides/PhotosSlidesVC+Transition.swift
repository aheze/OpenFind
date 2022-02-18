//
//  PhotosSlidesVC+Transition.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/17/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

extension PhotosSlidesViewController: PhotoTransitionAnimatorDelegate {
    func transitionWillStart() {
        
    }
    
    func transitionDidEnd() {
        
    }
    
    func referenceImage() -> UIImage? {
        return nil
    }
    
    func imageFrame() -> CGRect? {
        if
            let currentIndex = model.slidesState?.currentIndex,
            let viewController = model.slidesState?.findPhotos[safe: currentIndex]?.associatedViewController,
            let imageView = viewController.scrollZoomController.imageView
        {
            let frame = imageView.windowFrame()
            let normalizedFrame = CGRect.makeRect(aspectRatio: imageView.image?.size ?? .zero, insideRect: frame)
            return normalizedFrame
        }
        return nil
    }
}
