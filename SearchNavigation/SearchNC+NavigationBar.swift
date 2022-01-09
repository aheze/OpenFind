//
//  SearchNC+NavigationBar.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/9/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

extension SearchNavigationController {
    func setupNavigationBar() {
        self.title = "Lists"
        let clearAppearance = UINavigationBarAppearance()
        clearAppearance.configureWithTransparentBackground()
        
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.standardAppearance = clearAppearance
            navigationBar.compactAppearance = clearAppearance
            navigationBar.scrollEdgeAppearance = clearAppearance
            navigationBar.compactScrollEdgeAppearance = clearAppearance
        }
    }
    
    func createNavigationBarBackground() -> UIView {
        let backgroundView = UIView()
        view.addSubview(backgroundView)
    
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundView.rightAnchor.constraint(equalTo: view.rightAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: searchContainerView.bottomAnchor),
        ])
        
        backgroundView.addSubview(navigationBarBackgroundBlurView)
        navigationBarBackgroundBlurView.pinEdgesToSuperview()
        
        animator?.stopAnimation(true)
        animator?.finishAnimation(at: .start)
        animator = UIViewPropertyAnimator(duration: 1, curve: .linear)
        navigationBarBackgroundBlurView.effect = nil

        animator?.addAnimations { [weak navigationBarBackgroundBlurView] in
            navigationBarBackgroundBlurView?.effect = UIBlurEffect(style: .regular)
        }
        animator?.fractionComplete = 0
        
        view.bringSubviewToFront(searchContainerView)
        
        return backgroundView
    }
    
    func updateBlur() {
        let topPadding = searchConfiguration.getTotalHeight()
        
        /// relative to the top of the screen
        let contentOffset = -(scrollView.contentOffset.y - topPadding)
        
        if
            let navigationBar = navigationController?.navigationBar,
            let window = UIApplication.shared.keyWindow
        {
            let compactHeight = navigationBar.getCompactHeight() // 44 on iPhone 11
            let statusBarHeight = window.safeAreaInsets.top // 44 on iPhone 11
            let navigationBarHeight = compactHeight + statusBarHeight + topPadding
            
            let difference = max(0, contentOffset - navigationBarHeight)
            
            if difference < SearchNavigationConstants.blurFadeRange {
                let percentage = 1 - difference / SearchNavigationConstants.blurFadeRange
                animator?.fractionComplete = percentage
            } else {
                animator?.fractionComplete = 0
            }

        }
    }
}
