//
//  ViewController+Defaults.swift
//  Find
//
//  Created by Zheng on 1/28/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension ViewController {
    func readDefaults() {
        print("swipe? \(Defaults.swipeToNavigateEnabled)")
        longPressGestureRecognizer.isEnabled = Defaults.swipeToNavigateEnabled
        panGestureRecognizer.isEnabled = Defaults.swipeToNavigateEnabled
        
        DispatchQueue.main.async {
            self.camera.sortSearchTerms(removeExistingHighlights: false)
            for subView in self.camera.drawingView.subviews {
                subView.removeFromSuperview()
            }
            self.camera.drawHighlights(highlights: self.camera.currentComponents)
        }
    }
}
