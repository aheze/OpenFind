//
//  CameraVC+ScrollZoom.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/31/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//
    

import UIKit

extension CameraViewController {
    func createScrollZoom() -> ScrollZoomViewController{
        let storyboard = UIStoryboard(name: "ScrollZoomContent", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ScrollZoomViewController") as! ScrollZoomViewController
        addChildViewController(viewController, in: scrollZoomContainerView)
        
//        contentContainerView.addDebugBorders(.green)
        
        return viewController
    }
}


