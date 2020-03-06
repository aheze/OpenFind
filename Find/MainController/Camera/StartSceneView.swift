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
    
    func setUpTempImageView() {
        previewTempImageView.alpha = 0
        view.insertSubview(previewTempImageView, aboveSubview: cameraView)
        previewTempImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(cameraView)
        }
    }
    func blurScreenForSheetPresentation() {
        stopSession()
        
        
//        if let image = sceneView.session.currentFrame?.capturedImage {
//            //let uiImage = UIImage(pixelBuffer: image, sceneView: sceneView)
//            let uiImage = convertToUIImage(buffer: image)
//            newImageView.image = uiImage
//            newImageView.contentMode = .scaleAspectFill
//            newImageView.tag = 13571
//
//        }
        capturePhoto { image in
           //...
            self.previewTempImageView.image = image
            self.previewTempImageView.contentMode = .scaleAspectFill
            self.previewTempImageView.tag = 13571
            
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
            self.previewTempImageView.alpha = 1
        })
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
//            self.classicHasFoundOne = false
//            self.stopCoaching()
//            self.stopProcessingImage = true
////            self.classicTimer.suspend()
////            self.focusTimer.suspend()
////            //self.fastTimer.suspend()
////            self.newFastModeTimer?.invalidate()
////            self.sceneView.session.pause()
//        })
    }
//    func cancelSceneView() {
//        let newImageView = UIImageView()
//        newImageView.alpha = 0
//        view.insertSubview(newImageView, aboveSubview: cameraView)
//        newImageView.snp.makeConstraints { (make) in
//            make.edges.equalTo(cameraView)
//        }
////        if let image = sceneView.session.currentFrame?.capturedImage {
////            //let uiImage = UIImage(pixelBuffer: image, sceneView: sceneView)
////            let uiImage = convertToUIImage(buffer: image)
////            newImageView.image = uiImage
////            newImageView.contentMode = .scaleAspectFill
////            newImageView.tag = 13571
////
////        }
//        capturePhoto { image in
//           //...
//            newImageView.image = image
//            newImageView.contentMode = .scaleAspectFill
//            newImageView.tag = 13571
//
//        }
//        UIView.animate(withDuration: 0.5, animations: {
//            newImageView.alpha = 1
//        })
////        sceneView.session.pause()
////        self.newFastModeTimer?.invalidate()
//        //fastTimer.suspend()
//        //fastFindingToggle = .inactive
//        busyFastFinding = true
//        hasStartedDismissing = false
//
//    }
    func startVideo(finish: String) {
        switch finish {
//        case "start":
//            if let imageView = view.viewWithTag(13571) {
//                UIView.animate(withDuration: 0.5, delay: 0.8, animations: {
//                    imageView.alpha = 0
//                }, completion:  { _ in
//                    imageView.removeFromSuperview()
//                })
//            }
//            hasStartedDismissing = true
//            startSession()
        //    sceneView.session.run(fastSceneConfiguration)
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
//            if let imageView = view.viewWithTag(13571) {
//                print("yes image")
                UIView.animate(withDuration: 0.24, delay: 0.5, animations: {
                    self.previewTempImageView.alpha = 0
                }
                    
//                    , completion:  { _ in
//                    imageView.removeFromSuperview()
//                }
                
                )
//            } else {
//                print("no  image")
////                print("no")
//            }
            
            busyFastFinding = false
//            if hasStartedDismissing == true {
//                print("started dismissing")
//                UIView.animate(withDuration: 0.6, animations: {
//                    self.blurView.alpha = 0
//                }, completion: { _ in
//                    self.blurView.removeFromSuperview()
//                    self.hasStartedDismissing = false
//                })
//            } else {
                print("ended")
//                sceneView.session.run(fastSceneConfiguration)
                startSession()
                UIView.animate(withDuration: 0.6, animations: {
                    self.blurView.alpha = 0
                }, completion: { _ in
                    self.blurView.removeFromSuperview()
                    //self.hasStartedDismissing = false
                })
//            }
            
        default:
            print("wrong startsceneview")
            
        }
    }
    
}
