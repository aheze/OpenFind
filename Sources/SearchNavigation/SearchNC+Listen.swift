//
//  SearchNC+Listen.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

extension SearchNavigationController {
    func listen() {
        model.showNavigationBar = { [weak self] show in
            guard let self = self else { return }
            self.showNavigationBar(show: show)
        }
    }
    
    func showNavigationBar(show: Bool) {
        if show {
            navigation.setNavigationBarHidden(false, animated: true)
            searchContainerViewContainerTopC?.constant = 0
            UIView.animate(withDuration: 0.3) {
                self.navigationBarBackground.alpha = 1
                self.searchContainerView.alpha = 1
                self.navigationBarBackground.transform = .identity
                
                self.detailsSearchViewController?.view.transform = .identity
                self.searchViewController.view.transform = .identity
                self.view.layoutIfNeeded()
            }
            
        } else {
            navigation.setNavigationBarHidden(true, animated: true)
            searchContainerViewContainerTopC?.constant = -200
            UIView.animate(withDuration: 0.3) {
                self.navigationBarBackground.alpha = 0
                self.searchContainerView.alpha = 0
                self.navigationBarBackground.transform = CGAffineTransform(translationX: 0, y: -200)
                self.view.layoutIfNeeded()
            }
        }
    }
}
