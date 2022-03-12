//
//  CameraVC+Blur.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

/**
 Blur the entire camera when transitioning between tabs.
 */

extension CameraViewController {
    func setupBlur() {
        view.addSubview(blurOverlayView)
        blurOverlayView.pinEdgesToSuperview()
        
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.blurOverlayView.setupBlur()
            self.updateBlurProgress(to: self.tabViewModel.animatorProgress)
        }
    }

    func updateBlurProgress(to progress: CGFloat) {
        blurOverlayView.animator?.fractionComplete = progress
        switch tabViewModel.tabState {
        case .photos, .cameraToPhotos:
            blurOverlayView.colorView.backgroundColor = .systemBackground
        case .lists, .cameraToLists:
            blurOverlayView.colorView.backgroundColor = .secondarySystemBackground
        default:
            break
        }
    }
}

class CameraBlurOverlayView: UIView {
    var animator: UIViewPropertyAnimator?
    lazy var blurView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        addSubview(view)
        view.pinEdgesToSuperview()
        return view
    }()
    
    lazy var colorView: UIView = {
        let view = UIView()
        addSubview(view)
        view.pinEdgesToSuperview()
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        _ = blurView
        _ = colorView
        setupBlur()
        self.isUserInteractionEnabled = false
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupBlur() {
        animator?.stopAnimation(false)
        animator?.finishAnimation(at: .end)
        animator = UIViewPropertyAnimator(duration: 0.1, curve: .linear)
        blurView.effect = nil
        colorView.alpha = 0
        animator?.addAnimations { [weak blurView, weak colorView] in
            blurView?.effect = Constants.tabBlurEffect
            colorView?.alpha = 1
        }
        
        animator?.startAnimation()
        animator?.pauseAnimation()
        animator?.fractionComplete = 0
        animator?.pausesOnCompletion = true
    }
}
