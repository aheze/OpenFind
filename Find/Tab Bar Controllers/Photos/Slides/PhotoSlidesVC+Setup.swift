//
//  PhotoSlidesVC+Setup.swift
//  Find
//
//  Created by Zheng on 1/9/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotoSlidesViewController {
    func setupDelegates() {
        pageViewController.delegate = self
        pageViewController.dataSource = self
    }
    func setupGestures() {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanWith(gestureRecognizer:)))
        panGestureRecognizer.delegate = self
        pageViewController.view.addGestureRecognizer(self.panGestureRecognizer)
    
        singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didSingleTapWith(gestureRecognizer:)))
        pageViewController.view.addGestureRecognizer(self.singleTapGestureRecognizer)
    }
}
