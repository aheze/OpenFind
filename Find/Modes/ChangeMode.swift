//
//  ChangeMode.swift
//  Find
//
//  Created by Andrew on 10/25/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit
import ARKit

extension ViewController {
    //MARK: blur screen
    func blurScreen(mode toFocusMode: Bool) {
        let effect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: effect)
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.alpha = 0
        view.addSubview(blurView)
        view.bringSubviewToFront(blurView)
        view.bringSubviewToFront(photoButton)
        view.bringSubviewToFront(modeButton)
        view.bringSubviewToFront(shutterButton)
        view.bringSubviewToFront(refreshButton)
        view.bringSubviewToFront(menuButton)
        view.bringSubviewToFront(ramReel.view)
        
        if toFocusMode == false {
            //to classic
        UIView.animate(withDuration: 0.2, animations: {blurView.alpha = 1}, completion: { _ in
            
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
        
            self.sceneView.session.pause()
            self.sceneView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
            self.modeButton.imageView.image = #imageLiteral(resourceName: "bfocus 2")
    
        })
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
                UIView.animate(withDuration: 0.5, animations: {blurView.alpha = 0}, completion: {_ in           blurView.removeFromSuperview()})
            })
            
            
            
        } else {
            if let tag1 = self.view.viewWithTag(1) {
                print("1")
                self.view.bringSubviewToFront(tag1)
            }
            if let tag2 = self.view.viewWithTag(2) {
                 print("2")
                self.view.bringSubviewToFront(tag2)
            }
            //focusmode
        UIView.animate(withDuration: 0.2, animations: {blurView.alpha = 1}, completion: { _ in
            UIView.animate(withDuration: 0.2, animations: {
                print("alpha")
                if let tag1 = self.view.viewWithTag(1) {
                    tag1.alpha = 1
                }
                if let tag2 = self.view.viewWithTag(2) {
                    tag2.alpha = 1
                }
            })
                let action = SCNAction.fadeOut(duration: 1)
                for h in self.classicHighlightArray {
                    h.runAction(action, completionHandler: {() in
                        h.removeFromParentNode()
                        print("remove")
                    })
                }
                for h in self.secondClassicHighlightArray {
                        h.runAction(action, completionHandler: {
                            () in h.removeFromParentNode()
                            print("remove123")
                        })
                }

            self.sceneView.session.pause()
            self.runImageTrackingSession(with: [], runOptions: [.removeExistingAnchors, .resetTracking])
            self.modeButton.imageView.image = #imageLiteral(resourceName: "bclassic 2")

     
        })
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
                UIView.animate(withDuration: 0.5, animations: {blurView.alpha = 0}, completion: {_ in           blurView.removeFromSuperview()})
            })
        }
    }
}
