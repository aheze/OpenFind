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
    
    func setScrollZoomImage(image: UIImage) {
        scrollZoomViewController.imageView.image = image
        
        let contentViewBounds = scrollZoomViewController.contentView.frame
        let scrollViewBounds = scrollZoomViewController.scrollView.frame
        print("\(contentViewBounds) vs \(scrollViewBounds)")
        
        UIView.animate(withDuration: 0.5) {
            self.scrollZoomViewController.imageView.alpha = 1
        }
    }
    
    func removeScrollZoomImage() {
        UIView.animate(withDuration: 0.5) {
            self.scrollZoomViewController.imageView.alpha = 0
        }
    }
}


