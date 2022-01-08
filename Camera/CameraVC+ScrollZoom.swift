//
//  CameraVC+ScrollZoom.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/31/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//


import UIKit

extension CameraViewController {
    func createScrollZoom() -> ScrollZoomViewController {
        let storyboard = UIStoryboard(name: "ScrollZoomContent", bundle: nil)
        let scrollZoomViewController = storyboard.instantiateViewController(withIdentifier: "ScrollZoomViewController") as! ScrollZoomViewController
        addChildViewController(scrollZoomViewController, in: scrollZoomContainerView)
        
        scrollZoomViewController.imageView.alpha = 0
        return scrollZoomViewController
    }
    
    func createScrollZoomHook() -> ScrollZoomHookViewController {
        let storyboard = UIStoryboard(name: "ScrollZoomContent", bundle: nil)
        let scrollZoomHookViewController = storyboard.instantiateViewController(withIdentifier: "ScrollZoomHookViewController") as! ScrollZoomHookViewController
        addChildViewController(scrollZoomHookViewController, in: scrollZoomHookContainerView)
        
        scrollZoomHookViewController.zoomed = { [weak self] scrollViewZoom in
            guard let self = self else { return }
            if !self.cameraViewModel.shutterOn {
                let percentage = self.getPercentageFrom(scrollViewZoom: scrollViewZoom)
                self.zoomViewModel.percentage = percentage
                self.zoomViewModel.keepingExpandedUUID = nil
                self.zoomViewModel.setZoom(percentage: percentage)
                self.zoomViewModel.updateActivationProgress(percentage: percentage)
                self.livePreviewViewController.changeZoom(to: self.zoomViewModel.zoom, animated: true)
                
                self.zoomViewModel.savedExpandedOffset = -percentage * self.zoomViewModel.sliderWidth
                self.zoomViewModel.updateActivationProgress(
                    percentage: self.zoomViewModel.percentage(
                        totalOffset: self.zoomViewModel.savedExpandedOffset
                    )
                )
            }
        }
        
        scrollZoomHookViewController.stoppedZooming = { [weak self] in
            guard let self = self else { return }
            self.zoomViewModel.keepingExpandedUUID = UUID()
            self.zoomViewModel.startTimeout()
        }
        
        scrollZoomHookViewController.scrollView.minimumZoomScale = ZoomConstants.scrollViewMinZoom
        scrollZoomHookViewController.scrollView.maximumZoomScale = ZoomConstants.scrollViewMaxZoom
        return scrollZoomHookViewController
    }
    
    func setScrollZoomImage(image: UIImage) {
        self.scrollZoomContainerView.isUserInteractionEnabled = true
        self.scrollZoomHookContainerView.isUserInteractionEnabled = false
        
        scrollZoomViewController.imageView.image = image
        scrollZoomViewController.centerImage()
        
        UIView.animate(withDuration: 0.5) {
            self.scrollZoomViewController.imageView.alpha = 1
        }
    }
    
    func removeScrollZoomImage() {
        UIView.animate(withDuration: 0.5) {
            self.scrollZoomViewController.imageView.alpha = 0
            self.scrollZoomViewController.scrollView.zoomScale = 1
        } completion: { _ in
            self.scrollZoomContainerView.isUserInteractionEnabled = false
            self.scrollZoomHookContainerView.isUserInteractionEnabled = true
        }
    }
}


