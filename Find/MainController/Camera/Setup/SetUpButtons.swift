//
//  SetUpButtons.swift
//  Find
//
//  Created by Andrew on 11/11/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit
import SwiftEntryKit
import AVFoundation

extension ViewController: UIAdaptivePresentationControllerDelegate, UIGestureRecognizerDelegate {
   
    
   
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        print("Did Dismiss")
        if cancelTimer != nil {
            cancelTimer!.invalidate()
            cancelTimer = nil
        }
        SwiftEntryKit.dismiss()
        startVideo(finish: "end")
        listsCollectionView.reloadData()
    }
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        print("Start Dismiss")
        hasStartedDismissing = true
        startVideo(finish: "start")
        if cancelTimer == nil {
        cancelTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
        }
    }
    @objc func updateTimer() {
        cancelSeconds += 1
        if cancelSeconds == 5 {
            print("hit 5 secs")
            if cancelTimer != nil {
                cancelTimer!.invalidate()
                cancelTimer = nil
            }
            cancelSeconds = 0
            cancelSceneView()
        }
        
        //This will decrement(count down)the seconds.
        //timerLabel.text = "\(seconds)"
    }
//    @objc func doubleTapped() {
//        print("sdfjg")
//        // do something here
//        //refreshScreen(touch: UITapGestureRecognizer)
//        if doubleTap.state == UIGestureRecognizer.State.recognized {
//            print(doubleTap.location(in: doubleTap.view))
//        }
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        if segue.identifier == "goToHistory" {
    //            print("hist")
    //            let destinationVC = segue.destination as! HistoryViewController
    //            destinationVC.folderURL = globalUrl
    //        } else if segue.identifier == "goToSettings" {
    //            print("prepareSett")
    //        }
            switch segue.identifier {
            case "goToHistory":
                print("hist")
                let destinationVC = segue.destination as! HistoryViewController
                destinationVC.folderURL = globalUrl
            case "goToSettings":
                print("prepare settings")
                segue.destination.presentationController?.delegate = self
            case "goToNewHistory":
                segue.destination.presentationController?.delegate = self
                let destinationVC = segue.destination as! NewHistoryViewController
                destinationVC.folderURL = globalUrl
                //destinationVC.modalPresentationStyle = .fullScreen
            case "goToLists" :
                segue.destination.presentationController?.delegate = self
            case "goToFullScreen":
                print("full screen")
                default:
                    print("default, something wrong")
            }
            
            
        }
    func toFast() {
        self.blurScreen(mode: "fast")
    }
    @objc func tappedOnce(gr: UITapGestureRecognizer) {
        
        
        let loc: CGPoint = gr.location(in: gr.view)
        let screenSize = cameraView.videoPreviewLayer.bounds.size
        let x = loc.y / screenSize.height
        let y = loc.x / screenSize.width
        let focusPoint = CGPoint(x: x, y: y)

        if let device = cameraDevice {
            do {
                try device.lockForConfiguration()

                device.focusPointOfInterest = focusPoint
                //device.focusMode = .continuousAutoFocus
                device.focusMode = .autoFocus
                //device.focusMode = .locked
                device.exposurePointOfInterest = focusPoint
                device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
                device.unlockForConfiguration()
            }
            catch {
                // just ignore
            }
        }
        //refreshScreen(location: loc)
    }
    func setUpButtons() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedOnce))
        tap.numberOfTapsRequired = 1
        tap.delegate = self
        
        view.addGestureRecognizer(tap)
        view.bringSubviewToFront(numberLabel)
        
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 55, weight: .semibold)
        let listImage = UIImage(systemName: "square.grid.2x2.fill", withConfiguration: symbolConfiguration)?.withTintColor(UIColor(named: "DarkGray") ?? .black, renderingMode: .alwaysOriginal)
        let histImage = UIImage(systemName: "arrow.counterclockwise.circle.fill", withConfiguration: symbolConfiguration)?.withTintColor(UIColor(named: "DarkGray") ?? .black, renderingMode: .alwaysOriginal)
        let settImage = UIImage(systemName: "gear", withConfiguration: symbolConfiguration)?.withTintColor(UIColor(named: "DarkGray") ?? .black, renderingMode: .alwaysOriginal)
        
        let goToSett = menuButton.addItem()
        goToSett.tag = 12462
        goToSett.titleLabel.text = "Settings"
        goToSett.imageView.image = settImage
        goToSett.action = { item in
            print("settings")
            self.blurScreenForSheetPresentation()
            self.performSegue(withIdentifier: "goToSettings", sender: self)
        }
        let goToNewHistory = menuButton.addItem()
        goToNewHistory.tag = 12461
        goToNewHistory.titleLabel.text = "History"
        
        
        
        
        goToNewHistory.imageView.image = histImage
        goToNewHistory.action = { item in
            self.blurScreenForSheetPresentation()
            self.performSegue(withIdentifier: "goToNewHistory", sender: self)
        }
        let goToLists = menuButton.addItem()
        goToLists.tag = 12463
        goToLists.titleLabel.text = "Lists"
        goToLists.imageView.image = listImage
        goToLists.action = { item in
            self.blurScreenForSheetPresentation()
            self.performSegue(withIdentifier: "goToLists", sender: self)
        }
        
        menuButton.overlayView.backgroundColor = UIColor.clear
    }

    
}
extension ViewController {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        //print(touch.view)
        if view.viewWithTag(12461) != nil {
            return false
        }
        if view.viewWithTag(12462) != nil {
            return false
        }
        if view.viewWithTag(12463) != nil {
            return false
        }
        
        switch touch.view {
        case newShutterButton, menuButton, statusView, darkBlurEffect, blurView:
            print("Special view")
            return false
        default:
            print("Not")
            return true
        }
        //return touch.view == gestureRecognizer.view
        
    }
}
