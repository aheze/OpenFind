//
//  ListsViewController+NavigationBar.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/8/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

extension ListsViewController {
    func setupNavigationBar() {
        self.title = "Lists"
        let clearAppearance = UINavigationBarAppearance()
        clearAppearance.configureWithTransparentBackground()
        navigationController?.navigationBar.standardAppearance = clearAppearance
        navigationController?.navigationBar.compactAppearance = clearAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = clearAppearance
        navigationController?.navigationBar.compactScrollEdgeAppearance = clearAppearance
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
        
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        backgroundView.addSubview(blurView)
        blurView.pinEdgesToSuperview()
        
        view.bringSubviewToFront(searchContainerView)
        return backgroundView
    }
}


