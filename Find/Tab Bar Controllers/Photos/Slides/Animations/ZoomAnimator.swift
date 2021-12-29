//
//  ZoomAnimator.swift
//  FluidPhoto
//
//  Created by Masamichi Ueta on 2016/12/23.
//  Copyright © 2016 Masmichi Ueta. All rights reserved.
//

import UIKit

protocol ZoomAnimatorDelegate: class {
    func transitionWillStartWith(zoomAnimator: ZoomAnimator)
    func transitionDidEndWith(zoomAnimator: ZoomAnimator)
    func referenceImageView(for zoomAnimator: ZoomAnimator) -> UIImageView?
    func referenceImageViewFrameInTransitioningView(for zoomAnimator: ZoomAnimator) -> CGRect?
}

class ZoomAnimator: NSObject {
    var cameFromFind = false /// if this is from Photo Finding
    var removedLast = false
    
    weak var fromDelegate: ZoomAnimatorDelegate?
    weak var toDelegate: ZoomAnimatorDelegate?

    var transitionImageView: UIImageView?
    var isPresenting: Bool = true
    
    var finishedDismissing: Bool = false
    
    fileprivate func animateZoomInTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        guard let toVC = transitionContext.viewController(forKey: .to),
              let fromVC = transitionContext.viewController(forKey: .from),
              let fromReferenceImageView = fromDelegate?.referenceImageView(for: self),
              let toReferenceImageView = toDelegate?.referenceImageView(for: self),
              let fromReferenceImageViewFrame = fromDelegate?.referenceImageViewFrameInTransitioningView(for: self)
        else {
            return
        }
        
        fromDelegate?.transitionWillStartWith(zoomAnimator: self)
        toDelegate?.transitionWillStartWith(zoomAnimator: self)
        
        toVC.view.alpha = 0
        toReferenceImageView.isHidden = true
        containerView.addSubview(toVC.view)
        
        let referenceImage = fromReferenceImageView.image ?? UIImage()
        if transitionImageView == nil {
            let transitionImageView = UIImageView(image: referenceImage)
            transitionImageView.contentMode = .scaleAspectFill
            transitionImageView.clipsToBounds = true
            transitionImageView.frame = fromReferenceImageViewFrame
            self.transitionImageView = transitionImageView
            containerView.addSubview(transitionImageView)
        }
        
        fromReferenceImageView.isHidden = true
        
        if cameFromFind {
            transitionImageView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            transitionImageView?.layer.cornerRadius = 8
        }
        
        let finalTransitionSize = calculateZoomInImageFrame(image: referenceImage, forView: toVC.view)
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0,
            options: [UIView.AnimationOptions.transitionCrossDissolve],
            animations: {
                self.transitionImageView?.frame = finalTransitionSize
                
                if self.cameFromFind {
                    self.transitionImageView?.layer.cornerRadius = 0
                }
                
                toVC.view.alpha = 1.0
                fromVC.tabBarController?.tabBar.alpha = 0
            },
            completion: { _ in
                
                self.transitionImageView?.removeFromSuperview()
                toReferenceImageView.isHidden = false
                fromReferenceImageView.isHidden = false
                
                self.transitionImageView = nil
                
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                self.toDelegate?.transitionDidEndWith(zoomAnimator: self)
                self.fromDelegate?.transitionDidEndWith(zoomAnimator: self)
            }
        )
    }
    
    fileprivate func animateZoomOutTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        var toReferenceImageViewOptional: UIImageView?
        var toReferenceImageViewFrameOptional: CGRect?
        
        if removedLast {
            toReferenceImageViewOptional = UIImageView()
            toReferenceImageViewFrameOptional = CGRect(x: (UIScreen.main.bounds.width / 2) - 50, y: UIScreen.main.bounds.height + 200, width: 100, height: 100)
        } else {
            toReferenceImageViewOptional = toDelegate?.referenceImageView(for: self)
            toReferenceImageViewFrameOptional = toDelegate?.referenceImageViewFrameInTransitioningView(for: self)
        }
        
        guard let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
              let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
              let fromReferenceImageView = fromDelegate?.referenceImageView(for: self),
              let toReferenceImageView = toReferenceImageViewOptional,
              let fromReferenceImageViewFrame = fromDelegate?.referenceImageViewFrameInTransitioningView(for: self),
              let toReferenceImageViewFrame = toReferenceImageViewFrameOptional
        else {
            return
        }
        
        fromDelegate?.transitionWillStartWith(zoomAnimator: self)
        toDelegate?.transitionWillStartWith(zoomAnimator: self)
        
        toReferenceImageView.isHidden = true
        
        let referenceImage = fromReferenceImageView.image!
        
        if transitionImageView == nil {
            let transitionImageView = UIImageView(image: referenceImage)
            transitionImageView.contentMode = .scaleAspectFill
            transitionImageView.clipsToBounds = true
            transitionImageView.frame = fromReferenceImageViewFrame
            self.transitionImageView = transitionImageView
            containerView.addSubview(transitionImageView)
        }
        
        if cameFromFind {
            transitionImageView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        }
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        fromReferenceImageView.isHidden = true
        
        let finalTransitionSize = toReferenceImageViewFrame
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0,
                       options: [],
                       animations: {
                           fromVC.view.alpha = 0
                           self.transitionImageView?.frame = finalTransitionSize
                           if self.cameFromFind {
                               self.transitionImageView?.layer.cornerRadius = 8
                           }
                       }, completion: { _ in
                           self.finishedDismissing = true
            
                           self.transitionImageView?.removeFromSuperview()
                           toReferenceImageView.isHidden = false
                           fromReferenceImageView.isHidden = false
            
                           transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                           self.toDelegate?.transitionDidEndWith(zoomAnimator: self)
                           self.fromDelegate?.transitionDidEndWith(zoomAnimator: self)

                       })
    }
    
    private func calculateZoomInImageFrame(image: UIImage, forView view: UIView) -> CGRect {
        let viewRatio = view.frame.size.width / view.frame.size.height
        let imageRatio = image.size.width / image.size.height
        let touchesSides = (imageRatio > viewRatio)
        
        if touchesSides {
            let height = view.frame.width / imageRatio
            let yPoint = view.frame.minY + (view.frame.height - height) / 2
            return CGRect(x: 0, y: yPoint, width: view.frame.width, height: height)
        } else {
            let width = view.frame.height * imageRatio
            let xPoint = view.frame.minX + (view.frame.width - width) / 2
            return CGRect(x: xPoint, y: 0, width: width, height: view.frame.height)
        }
    }
}

extension ZoomAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if isPresenting {
            return 0.5
        } else {
            return 0.25
        }
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting {
            animateZoomInTransition(using: transitionContext)
        } else {
            animateZoomOutTransition(using: transitionContext)
        }
    }
}
