//
//  PhotoSlidesVC+ScreenMode.swift
//  Find
//
//  Created by Zheng on 1/23/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotoSlidesViewController {
    func changeScreenMode(to: ScreenMode) {
        if to == .full {
            if self.cameFromFind {
                UIView.animate(withDuration: 0.25) {
                    self.backButtonView.alpha = 0
                }
            } else {
                if self.findPressed {
                    slideFindBarTopC?.update(offset: -45)
                }
                UIView.animate(withDuration: 0.25) {
                    
                    self.navigationController?.setNavigationBarHidden(true, animated: false)
                    self.view.backgroundColor = .black
                    self.view.layoutIfNeeded()
                    self.slideFindBar?.alpha = 0
                    
                }
                hideTabBar?(true)
            }
            
        } else {
            if self.cameFromFind {
                UIView.animate(withDuration: 0.25) {
                    self.backButtonView.alpha = 1
                }
            } else {
                if self.findPressed {
                    slideFindBarTopC?.update(offset: 0)
                }
                UIView.animate(withDuration: 0.25) {
                    self.navigationController?.setNavigationBarHidden(false, animated: false)
                    self.view.backgroundColor = .systemBackground
                    self.view.layoutIfNeeded()
                    if self.findPressed {
                        self.slideFindBar?.alpha = 1
                    }
                }
                
                hideTabBar?(false)
            }
        }
    }
}
