//
//  PhotosTransitionDismissAnimator.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/17/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

/// interactive dismissal
final class PhotosTransitionDismissAnimator: NSObject, UIViewControllerInteractiveTransitioning {
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

    /// The background animation is the "photo-detail background opacity goes to zero"
    fileprivate var backgroundAlphaAnimator: UIViewPropertyAnimator?

    // NOTE: To avoid writing tons of boilerplate that pulls these values out of
    // the transitionContext, I'm just gonna cache them here.

    fileprivate weak var fromVC: PhotosSlidesViewController?
    fileprivate weak var toVC: UIViewController?
    fileprivate var transitionContext: UIViewControllerContextTransitioning?
    fileprivate var fromImageViewFrame: CGRect?
    fileprivate var toImageViewFrame: CGRect?
    fileprivate var fromImage: UIImage?

    /// The snapshotView that is animating between the two view controllers.
    let transitionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.accessibilityIgnoresInvertColors = true
        return imageView
    }()

    /// from 0 (just started dragging) to 1 (should animate pop)
    var progressUpdated: ((CGFloat) -> Void)?

    var additionalFinalSetup: (() -> Void)?
    
    var additionalFinalAnimations: (() -> Void)?

    /// true if succeeded
    var additionalCompletion: ((Bool) -> Void)?

    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: .from) as? PhotosSlidesViewController,
            let toVC = transitionContext.viewController(forKey: .to),
            let slidesView = transitionContext.view(forKey: .from),
            let photosView = transitionContext.view(forKey: .to),
            let fromImageViewFrame = fromDelegate.imageFrame(type: .pop),
            let toImageViewFrame = toDelegate.imageFrame(type: .pop),
            let fromImage = fromDelegate.referenceImage(type: .pop)
        else {
            fatalError()
        }

        fromVC.transitionAnimator = self
        self.fromVC = fromVC
        self.toVC = toVC
        self.transitionContext = transitionContext
        self.fromImageViewFrame = fromImageViewFrame
        self.toImageViewFrame = toImageViewFrame
        self.fromImage = fromImage

        let containerView = transitionContext.containerView

        transitionImageView.frame = fromImageViewFrame
        transitionImageView.image = fromImage

        containerView.addSubview(photosView)
        containerView.addSubview(slidesView)
        containerView.addSubview(transitionImageView)

        // NOTE: The duration and damping ratio here don't matter!
        // This animation is only programmatically adjusted in the drag state,
        // and then the duration is altered in the completion state.
        let backgroundAlphaAnimator = UIViewPropertyAnimator(duration: 1, dampingRatio: 1) {
            slidesView.alpha = 0
        }
        self.backgroundAlphaAnimator = backgroundAlphaAnimator

        toDelegate.transitionWillStart(type: .pop)
        fromDelegate.transitionWillStart(type: .pop)
    }
}

extension PhotosTransitionDismissAnimator {
    /// Called by the photo-detail screen, this function updates the state of
    /// the interactive transition, based on the state of the gesture.
    func didPanWith(gestureRecognizer: UIPanGestureRecognizer) {
        guard let transitionContext = transitionContext else { return }
        let transitionImageView = self.transitionImageView
        let translation = gestureRecognizer.translation(in: nil)
        let translationVertical = translation.y

        // For a given vertical-drag, we calculate our percentage complete
        // and how shrunk-down the transition-image should be.
        let percentageComplete = self.percentageComplete(forVerticalDrag: translationVertical)
        let transitionImageScale = transitionImageScaleFor(percentageComplete: percentageComplete)

        switch gestureRecognizer.state {
        case .possible, .began:
            break
        case .cancelled, .failed:
            completeTransition(didCancel: true)
        case .changed:
            transitionImageView.transform = CGAffineTransform.identity
                .scaledBy(x: transitionImageScale, y: transitionImageScale)
                .translatedBy(x: translation.x, y: translation.y)

            transitionContext.updateInteractiveTransition(percentageComplete)
            backgroundAlphaAnimator?.fractionComplete = percentageComplete
            progressUpdated?(percentageComplete)
        case .ended:
            // Here, we decide whether to complete or cancel the transition.
            let fingerIsMovingDownwards = gestureRecognizer.velocity(in: nil).y > 0
            let transitionMadeSignificantProgress = percentageComplete > 0.1
            let shouldComplete = fingerIsMovingDownwards && transitionMadeSignificantProgress
            completeTransition(didCancel: !shouldComplete)
        @unknown default:
            break
        }
    }

    func completeTransition(didCancel: Bool) {
        // If the gesture was cancelled, we reverse the "fade out the photo-detail background" animation.
        self.backgroundAlphaAnimator?.isReversed = didCancel

        let transitionContext = self.transitionContext!
        let backgroundAlphaAnimator = self.backgroundAlphaAnimator!

        // The cancel and complete animations have different timing values.
        // I dialed these in on-device using SwiftTweaks.
        let completionDuration: Double
        let completionDamping: CGFloat
        if didCancel {
            completionDuration = 0.45
            completionDamping = 0.75
        } else {
            completionDuration = 0.37
            completionDamping = 0.90
        }

        // The transition-image needs to animate into its final place.
        // That's either:
        // - its original spot on the photo-detail screen (if the transition was cancelled),
        // - or its place in the photo-grid (if the transition completed).
        let foregroundAnimator = UIViewPropertyAnimator(duration: completionDuration, dampingRatio: completionDamping) {
            // Reset our scale-transform on the image view
            self.transitionImageView.transform = CGAffineTransform.identity

            // NOTE: It's important that we ask the toDelegate *here*,
            // because if the device has rotated,
            // the toDelegate needs a chance to update its layout
            // before asking for the frame.
            self.transitionImageView.frame = didCancel
                ? self.fromImageViewFrame!
                : self.toDelegate.imageFrame(type: .pop) ?? self.toImageViewFrame!
            
            self.additionalFinalAnimations?()
        }

        // When the transition-image has moved into place, the animation completes,
        // and we close out the transition itself.
        foregroundAnimator.addCompletion { [weak self] position in
            self?.transitionImageView.removeFromSuperview()
            self?.transitionImageView.image = nil
            self?.toDelegate.transitionDidEnd(type: .pop)
            self?.fromDelegate.transitionDidEnd(type: .pop)

            if didCancel {
                transitionContext.cancelInteractiveTransition()
            } else {
                transitionContext.finishInteractiveTransition()
            }
            transitionContext.completeTransition(!didCancel)
            self?.transitionContext = nil
            self?.additionalCompletion?(!didCancel)
        }

        // Update the backgroundAnimation's duration to match.
        // PS: How *cool* are property-animators? I say: very. This "continue animation" bit is magic!
        let durationFactor = CGFloat(foregroundAnimator.duration / backgroundAlphaAnimator.duration)
        backgroundAlphaAnimator.continueAnimation(withTimingParameters: nil, durationFactor: durationFactor)
        additionalFinalSetup?()
        foregroundAnimator.startAnimation()
    }
}

extension PhotosTransitionDismissAnimator {
    /// For a given vertical offset, what's the percentage complete for the transition?
    /// e.g. -100pts -> 0%, 0pts -> 0%, 20pts -> 10%, 200pts -> 100%, 400pts -> 100%
    private func percentageComplete(forVerticalDrag verticalDrag: CGFloat) -> CGFloat {
        let maximumDelta = CGFloat(200)
        return CGFloat.scaleAndShift(value: verticalDrag, inRange: (min: CGFloat(0), max: maximumDelta))
    }

    /// The transition image scales down from 100% to a minimum of 68%,
    /// based on the percentage-complete of the gesture.
    func transitionImageScaleFor(percentageComplete: CGFloat) -> CGFloat {
        let minScale = CGFloat(0.68)
        let result = 1 - (1 - minScale) * percentageComplete
        return result
    }
}

extension PhotosTransitionDismissAnimator: UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // Never called; this is always an interactive transition.
        fatalError()
    }
}
