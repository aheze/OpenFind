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
        
        scrollZoomViewController.zoomed = { [weak self] scrollViewZoom in
            guard let self = self else { return }
            if !self.cameraViewModel.shutterOn {
                let percentage = self.getPercentageFrom(scrollViewZoom: scrollViewZoom)
                
                print("Scroll Scale (pinched): \(scrollViewZoom). Percentage is: \(percentage)")
                
                DispatchQueue.main.async {
                    self.zoomViewModel.setZoom(positionInSlider: percentage)
                    print("Zoom is now \(self.zoomViewModel.zoom).")
                    self.livePreviewViewController.changeZoom(to: self.zoomViewModel.zoom, animated: true)
                }
                
                self.zoomViewModel.savedExpandedOffset = -percentage * self.zoomViewModel.sliderWidth
                self.zoomViewModel.updateActivationProgress(
                    positionInSlider: self.zoomViewModel.positionInSlider(
                        totalOffset: self.zoomViewModel.savedExpandedOffset
                    )
                )
                
            }
        }
        
        scrollZoomViewController.scrollView.minimumZoomScale = ZoomConstants.scrollViewMinZoom
        scrollZoomViewController.scrollView.maximumZoomScale = ZoomConstants.scrollViewMaxZoom
        
        return scrollZoomViewController
    }
    
    func setScrollZoomImage(image: UIImage) {
        scrollZoomViewController.scrollView.zoomScale = 1
        scrollZoomViewController.imageView.image = image
        hookScrollViewForZooming(false)
        
        UIView.animate(withDuration: 0.5) {
            self.scrollZoomViewController.imageView.alpha = 1
        }
    }
    
    func removeScrollZoomImage() {
        hookScrollViewForZooming(true)
        UIView.animate(withDuration: 0.5) {
            self.scrollZoomViewController.imageView.alpha = 0
        }
    }
}


