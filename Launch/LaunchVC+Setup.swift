//
//  LaunchVC+Setup.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import SwiftUI

extension LaunchViewController {
    func setup() {
        activityIndicator.alpha = 0
        sceneContainer.alpha = 0
        sceneContainer.backgroundColor = .clear
        contentContainer.backgroundColor = .clear
        view.backgroundColor = Colors.accentDarkBackground
        
        activityIndicatorTopC.constant = 50
        activityIndicator.color = .white
        activityIndicator.startAnimating()
        
        /// SwiftUI overlay
        setupView()
        
        UIView.animate(withDuration: 0.3) {
            self.activityIndicator.alpha = 1
        }
        
        if Debug.skipLaunchIntro {
            showUI()
        } else {
            /// need a bit of delay to ensure activity indicator showing
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.31) {
                self.setupScene()
            }
        }
        
        listen()
    }
}
