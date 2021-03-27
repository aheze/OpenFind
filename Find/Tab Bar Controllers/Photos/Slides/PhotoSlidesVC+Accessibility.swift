//
//  PhotoSlidesVC+Accessibility.swift
//  Find
//
//  Created by Zheng on 3/27/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit


extension PhotoSlidesViewController {
    func setupAccessibility() {
        if UIAccessibility.isVoiceOverRunning {
            messageView.isHidden = true
        }
    }
}
