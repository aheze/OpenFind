//
//  VC+BlurCamera.swift
//  FindAppClip1
//
//  Created by Zheng on 3/18/21.
//

import UIKit

extension ViewController {
    func blurCamera() {
        blurAnimator?.stopAnimation(true)
        blurAnimator?.finishAnimation(at: .start)
        blurAnimator = UIViewPropertyAnimator(duration: 1, curve: .linear)
        
        self.cameraViewController.blurView.effect = nil
        blurAnimator?.addAnimations {
            self.cameraViewController.blurView.effect = UIBlurEffect(style: .systemChromeMaterialDark)
        }
        blurAnimator?.startAnimation()
        blurAnimator?.pauseAnimation()
    }
}
