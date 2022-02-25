//
//  PhotosTransitionAnimator.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/17/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

enum PhotoTransitionAnimatorType {
    case push
    case pop
}
/// Allows view controllers to participate in the photo-detail transition animation.
protocol PhotoTransitionAnimatorDelegate: UIViewController {
    
    /// Called just-before the transition animation begins.
    /// Use this to prepare for the transition.
    func transitionWillStart(type: PhotoTransitionAnimatorType)

    /// Called right-after the transition animation ends.
    /// Use this to clean up after the transition.
    func transitionDidEnd(type: PhotoTransitionAnimatorType)

    /// The animator needs a UIImageView for the transition;
    /// eg the Photo Detail screen should provide a snapshotView of its image,
    /// and a collectionView should do the same for its image views.
    func referenceImage(type: PhotoTransitionAnimatorType) -> UIImage?

    /// The location onscreen for the imageView provided in `referenceImageView(for:)`
    func imageFrame(type: PhotoTransitionAnimatorType) -> CGRect?
    
    func imageCornerRadius(type: PhotoTransitionAnimatorType) -> CGFloat
}


