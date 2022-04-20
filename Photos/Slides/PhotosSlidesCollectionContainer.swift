//
//  PhotosSlidesCollectionContainer.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/19/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

class PhotosSlidesCollectionContainer: UIView {
    var model: PhotosViewModel?
    var increment: (() -> Void)?
    var decrement: (() -> Void)?

    override var accessibilityTraits: UIAccessibilityTraits {
        get {
            return .adjustable
        } set {
            super.accessibilityTraits = newValue
        }
    }

    override var accessibilityValue: String? {
        get {
            guard let slidesState = model?.slidesState else { return nil }
            if let currentIndex = slidesState.getCurrentIndex() {
                if slidesState.slidesPhotos.count == 1 {
                    return "\(currentIndex) out of \(slidesState.slidesPhotos.count) photo"
                } else {
                    return "\(currentIndex) out of \(slidesState.slidesPhotos.count) photos"
                }
            }
            return nil
        } set {
            super.accessibilityValue = newValue
        }
    }

    override func accessibilityIncrement() {
        increment?()
    }

    override func accessibilityDecrement() {
        decrement?()
    }
}
