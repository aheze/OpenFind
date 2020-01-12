//
//  StartSceneView.swift
//  Find
//
//  Created by Andrew on 1/3/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import ARKit

extension ViewController {
    
    func blurScreenForSheetPresentation() {
        let newImageView = UIImageView()
        newImageView.alpha = 0
        view.insertSubview(newImageView, aboveSubview: sceneView)
        newImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(sceneView)
        }
        if let image = sceneView.session.currentFrame?.capturedImage {
            //let uiImage = UIImage(pixelBuffer: image, sceneView: sceneView)
            let uiImage = convertToUIImage(buffer: image)
            newImageView.image = uiImage
            newImageView.contentMode = .scaleAspectFill
            newImageView.tag = 13571
        
        }
        let effect = UIBlurEffect(style: .light)
        
        //let blurView = UIVisualEffectView(effect: effect)
        blurView = UIVisualEffectView(effect: effect)
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.alpha = 0
        //blurView.tag = 12345
        view.addSubview(blurView)
        view.bringSubviewToFront(blurView)

        UIView.animate(withDuration: 0.5, animations: {
            self.blurView.alpha = 1
            newImageView.alpha = 1
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            self.classicHasFoundOne = false
            self.stopCoaching()
            self.stopProcessingImage = true
            self.classicTimer.suspend()
            self.focusTimer.suspend()
            //self.fastTimer.suspend()
            self.newFastModeTimer?.invalidate()
            self.sceneView.session.pause()
        })
    }
    func cancelSceneView() {
        let newImageView = UIImageView()
        newImageView.alpha = 0
        view.insertSubview(newImageView, aboveSubview: sceneView)
        newImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(sceneView)
        }
        if let image = sceneView.session.currentFrame?.capturedImage {
            //let uiImage = UIImage(pixelBuffer: image, sceneView: sceneView)
            let uiImage = convertToUIImage(buffer: image)
            newImageView.image = uiImage
            newImageView.contentMode = .scaleAspectFill
            newImageView.tag = 13571
        
        }
        UIView.animate(withDuration: 0.5, animations: {
            newImageView.alpha = 1
        })
        sceneView.session.pause()
        self.newFastModeTimer?.invalidate()
        //fastTimer.suspend()
        //fastFindingToggle = .inactive
        busyFastFinding = true
        hasStartedDismissing = false
        
    }
    func startSceneView(finish: String) {
        switch finish {
            
        case "start":
            if let imageView = view.viewWithTag(13571) {
                UIView.animate(withDuration: 0.5, delay: 0.5, animations: {
                    imageView.alpha = 0
                }, completion:  { _ in
                    imageView.removeFromSuperview()
                })
            }
            sceneView.session.run(fastSceneConfiguration)
//            let effect = UIBlurEffect(style: .light)
//            let blurView = UIVisualEffectView(effect: effect)
//            blurView.frame = view.bounds
//            blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//            blurView.alpha = 0
//            blurView.tag = 12345
//            view.addSubview(blurView)
//            view.bringSubviewToFront(blurView)
//
//            UIView.animate(withDuration: 0.6, animations: {
//                blurView.alpha = 1
//            })
        case "end":
            if let imageView = view.viewWithTag(13571) {
                print("yes")
                UIView.animate(withDuration: 0.3, delay: 0.5, animations: {
                    imageView.alpha = 0
                }, completion:  { _ in
                    imageView.removeFromSuperview()
                })
            } else {
                print("no")
            }
            scanModeToggle = .fast
            classicHasFoundOne = false
            stopCoaching()
            stopProcessingImage = true
            classicTimer.suspend()
            focusTimer.suspend()
         //   modeButton.imageView.image = #imageLiteral(resourceName: "bfast 2")
            //fastFindingToggle = .notBusy
            busyFastFinding = false
            //fastTimer.resume()
            newFastModeTimer = Timer.scheduledTimer(withTimeInterval: newFastUpdateInterval, repeats: true) { [weak self] _ in
                guard !self!.busyFastFinding else { return }
                if let capturedImage = self?.sceneView.session.currentFrame?.capturedImage {
                    self?.fastFind(in: capturedImage)
                }
            }
            if hasStartedDismissing == true {
                UIView.animate(withDuration: 0.6, animations: {
                    self.blurView.alpha = 0
                }, completion: { _ in
                    self.blurView.removeFromSuperview()
                    self.hasStartedDismissing = false
                })
            } else {
                sceneView.session.run(fastSceneConfiguration)
                UIView.animate(withDuration: 0.6, animations: {
                    self.blurView.alpha = 0
                }, completion: { _ in
                    self.blurView.removeFromSuperview()
                    //self.hasStartedDismissing = false
                })
            }
            
        default:
            print("wrong startsceneview")
            
        }
    }
    
}
