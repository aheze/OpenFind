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
                UIView.animate(withDuration: 0.25) {
                    self.view.backgroundColor = .black
                }
                self.slideFindBar?.alpha = 0
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                hideTabBar?(true)
            }
            
        } else {
            if self.cameFromFind {
                UIView.animate(withDuration: 0.25) {
                    self.backButtonView.alpha = 1
                }
            } else {
                UIView.animate(withDuration: 0.25) {
                    self.view.backgroundColor = .systemBackground
                }
                if self.findPressed {
                    self.slideFindBar?.alpha = 1
                }
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                hideTabBar?(false)
            }
        }
    }
}
