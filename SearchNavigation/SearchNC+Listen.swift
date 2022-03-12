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
            Tab.Control.showStatusBar?(true)
        } else {
            navigation.setNavigationBarHidden(true, animated: true)
            Tab.Control.showStatusBar?(false)
        }
    }
}
