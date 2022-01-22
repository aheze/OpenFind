//
//  SearchNC+NavigationBar.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/9/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//


import UIKit

extension SearchNavigationController {
    
    /// call this after embedding in a view controller
    func setupNavigationBar() {
        
        setupBackground()
        setupBlur()
        setupBorder()
        
        let clearAppearance = UINavigationBarAppearance()
        clearAppearance.configureWithTransparentBackground()
        
        let navigationBar = navigation.navigationBar
        navigationBar.standardAppearance = clearAppearance
        navigationBar.compactAppearance = clearAppearance
        navigationBar.scrollEdgeAppearance = clearAppearance
        navigationBar.compactScrollEdgeAppearance = clearAppearance
        navigationBar.prefersLargeTitles = true
    }
    
    func setupBackground() {
        navigationBarBackgroundContainer.isUserInteractionEnabled = false
        navigation.view.insertSubview(navigationBarBackgroundContainer, at: 1)
        navigationBarBackgroundContainer.pinEdgesToSuperview()
        
        let navigationBarBackgroundHeightC = navigationBarBackground.heightAnchor.constraint(equalToConstant: 0)
        self.navigationBarBackgroundHeightC = navigationBarBackgroundHeightC
        navigationBarBackgroundContainer.addSubview(navigationBarBackground)
        navigationBarBackground.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            navigationBarBackground.topAnchor.constraint(equalTo: navigationBarBackgroundContainer.topAnchor),
            navigationBarBackground.leftAnchor.constraint(equalTo: navigationBarBackgroundContainer.leftAnchor),
            navigationBarBackground.rightAnchor.constraint(equalTo: navigationBarBackgroundContainer.rightAnchor),
            navigationBarBackgroundHeightC
        ])
        

        navigationBarBackground.addSubview(navigationBarBackgroundBlurView)
        navigationBarBackgroundBlurView.pinEdgesToSuperview()
    }
    
    func setupBorder() {
        navigationBarBackground.addSubview(navigationBarBackgroundBorderView)
        navigationBarBackgroundBorderView.backgroundColor = testing ? .systemBlue : .secondaryLabel
        navigationBarBackgroundBorderView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            navigationBarBackgroundBorderView.leftAnchor.constraint(equalTo: navigationBarBackground.leftAnchor),
            navigationBarBackgroundBorderView.bottomAnchor.constraint(equalTo: navigationBarBackground.bottomAnchor),
            navigationBarBackgroundBorderView.rightAnchor.constraint(equalTo: navigationBarBackground.rightAnchor),
            navigationBarBackgroundBorderView.heightAnchor.constraint(equalToConstant: testing ? 6 : 0.5)
        ])
    }
    
    func setupBlur() {
        animator?.stopAnimation(true)
        animator?.finishAnimation(at: .start)
        animator = UIViewPropertyAnimator(duration: 1, curve: .linear)
        navigationBarBackgroundBlurView.effect = nil
        navigationBarBackgroundBorderView.alpha = 0
        
        animator?.addAnimations { [weak navigationBarBackgroundBlurView, weak navigationBarBackgroundBorderView] in
            navigationBarBackgroundBlurView?.effect = UIBlurEffect(style: .regular)
            navigationBarBackgroundBorderView?.alpha = 1
        }
        animator?.fractionComplete = 0
    }

}

extension UINavigationBar {
    func getCompactHeight() -> CGFloat {
        
        /// Loop through the navigation bar's subviews.
        for subview in subviews {
            
            /// Check if the subview is pinned to the top (compact bar) and contains a title label
            if subview.frame.origin.y == 0 && subview.subviews.contains(where: { $0 is UILabel }) {
                return subview.bounds.height
            }
        }
        
        return 0
    }
}
