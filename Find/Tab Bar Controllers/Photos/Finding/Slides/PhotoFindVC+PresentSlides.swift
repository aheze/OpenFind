//
//  PhotoFindVC+PresentSlides.swift
//  Find
//
//  Created by Zheng on 1/17/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotoFindViewController {
    /// set the currentlyPresenting and change the tab bar
    func changePresentationMode(presentingSlides: Bool) {
        if presentingSlides {
            currentlyPresentingSlides = true
            changePresentationMode?(true)
        } else {
            currentlyPresentingSlides = false
            changePresentationMode?(false)
        }
    }
}
