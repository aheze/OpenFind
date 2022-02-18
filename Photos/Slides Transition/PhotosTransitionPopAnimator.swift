//
//  PhotosTransitionPopAnimator.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/17/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

final class PhotosTransitionPopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    fileprivate let fromDelegate: PhotoTransitionAnimatorDelegate
    fileprivate let toDelegate: PhotoTransitionAnimatorDelegate

    /// If fromDelegate isn't PhotoDetailTransitionAnimatorDelegate, returns nil.
    init?(
        fromDelegate: PhotoTransitionAnimatorDelegate,
        toDelegate: PhotoTransitionAnimatorDelegate
    ) {
        self.fromDelegate = fromDelegate
        self.toDelegate = toDelegate
    }

    /// The snapshotView that is animating between the two view controllers.
    let transitionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.accessibilityIgnoresInvertColors = true
        return imageView
    }()
    
    /// for the navigation bar or any other animations
    var additionalSetup: (() -> Void)?
    var additionalAnimations: (() -> Void)?
    var additionalCompletion: (() -> Void)?

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // 4
        guard let slidesView = transitionContext.view(forKey: .from) else { return }
        guard let photosView = transitionContext.view(forKey: .to) else { return }

        // 5
        let duration = transitionDuration(using: transitionContext)

        // 6
        let containerView = transitionContext.containerView

        photosView.alpha = 0
        containerView.addSubview(photosView)

        let transitionImage = fromDelegate.referenceImage(type: .pop)
        transitionImageView.image = transitionImage
        containerView.addSubview(transitionImageView)

        if let fromImageFrame = fromDelegate.imageFrame(type: .pop) {
            transitionImageView.frame = fromImageFrame
        }

        // Now let's animate, using our old friend UIViewPropertyAnimator!
        let spring: CGFloat = 0.95
        let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: spring) {
            photosView.alpha = 1
        }
        
        // Once the animation is complete, we'll need to clean up.
        animator.addCompletion { position in
            // Remove the transition image
            self.transitionImageView.removeFromSuperview()
            self.transitionImageView.image = nil

            // Tell UIKit we're done with the transition
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)

            // Tell our view controllers that we're done, too.
            self.toDelegate.transitionDidEnd(type: .pop)
            self.fromDelegate.transitionDidEnd(type: .pop)
            self.additionalCompletion?()
        }

        // HACK: By delaying 0.005s, I get a layout-refresh on the toViewController,
        // which means its collection view has updated its layout,
        // and our toDelegate?.imageFrame() is accurate, even if
        // the device has rotated. :scream_cat:
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.005) {
            self.additionalSetup?()
            animator.addAnimations {
                if let toImageFrame = self.toDelegate.imageFrame(type: .pop) {
                    self.transitionImageView.frame = toImageFrame
                }
                self.additionalAnimations?()
            }
        }

        self.toDelegate.transitionWillStart(type: .pop)
        self.fromDelegate.transitionWillStart(type: .pop)
        animator.startAnimation()
    }
}
