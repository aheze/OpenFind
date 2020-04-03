//
//  ViewExtensions.swift
//  Find
//
//  Created by Andrew on 10/29/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit
import ARKit

///Blur Screen & Refresh Screen
extension ViewController {
    func blurScreen(mode: String) {
        let effect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: effect)
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.alpha = 0
        view.addSubview(blurView)
        view.bringSubviewToFront(blurView)
        view.bringSubviewToFront(newShutterButton)
        view.bringSubviewToFront(menuButton)
        guard let tag1 = self.view.viewWithTag(1) else {return}
        guard let tag2 = self.view.viewWithTag(2) else {return}
        UIView.animate(withDuration: 0.2, animations: {
            blurView.alpha = 1
            tag1.alpha = 0
            tag2.alpha = 0
        }, completion: { _ in
            self.busyFastFinding = false
            
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
            UIView.animate(withDuration: 0.3, animations: {blurView.alpha = 0}, completion: {_ in
                blurView.removeFromSuperview()})
            ///make it seem like it's FAST (the blur fades much faster)
        })
    }
}


