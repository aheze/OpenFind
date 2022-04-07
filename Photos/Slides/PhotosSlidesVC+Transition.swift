//
//  PhotosSlidesVC+Transition.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/17/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

extension PhotosSlidesViewController: PhotoTransitionAnimatorDelegate {
    func transitionWillStart(type: PhotoTransitionAnimatorType) {
        switch type {
        case .push:
            break
        case .pop:
            if let containerView = getCurrentItemContainerView() {
                containerView.alpha = 0
            }
        }
    }

    func transitionDidEnd(type: PhotoTransitionAnimatorType, completed: Bool) {
        if let containerView = getCurrentItemContainerView() {
            containerView.alpha = 1
        }
    }
    
    func referenceImage(type: PhotoTransitionAnimatorType) -> UIImage? {
        if let imageView = getCurrentItemImageView() {
            return imageView.image
        }
        return nil
    }
    
    func imageFrame(type: PhotoTransitionAnimatorType) -> CGRect? {
        let frame = getCurrentPhotoFrame() ?? .zero
        if model.slidesState?.toolbarInformationOn ?? false {
            return frame
        } else {
            let thumbnail = model.slidesState?.getCurrentSlidesPhoto()?.findPhoto.thumbnail
            let thumbnailSize = thumbnail?.size ?? .zero
            let normalizedFrame = CGRect.makeRect(aspectRatio: thumbnailSize, insideRect: frame)
            return normalizedFrame
        }
    }
    
    /// read frame directly from the `flowLayout` to prevent incorrect frame
    func getCurrentPhotoFrame() -> CGRect? {
        if
            let currentIndex = model.slidesState?.getCurrentIndex(),
            let attributes = flowLayout.layoutAttributes[safe: currentIndex]
        {
            let frame = CGRect(origin: .zero, size: attributes.frame.size)
            return frame
        }
        return nil
    }
    
    func getCurrentItemViewController() -> PhotosSlidesItemViewController? {
        if let photo = model.slidesState?.currentPhoto, let viewController = self.getViewController(for: photo) {
            return viewController   
        }
        return nil
    }
    
    func getCurrentItemContainerView() -> UIView? {
        if let viewController = getCurrentItemViewController() {
            if let containerView = viewController.containerView {
                return containerView
            }
        }
        return nil
    }
    
    func getCurrentItemImageView() -> UIImageView? {
        if
            let viewController = getCurrentItemViewController(),
            let imageView = viewController.scrollZoomController.imageView
        {
            return imageView
        }
        return nil
    }
    
    func imageCornerRadius(type: PhotoTransitionAnimatorType) -> CGFloat {
        return 0
    }
}
