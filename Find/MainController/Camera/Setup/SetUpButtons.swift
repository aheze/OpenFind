//
//  SetUpButtons.swift
//  Find
//
//  Created by Andrew on 11/11/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit
import SwiftEntryKit

extension ViewController: UIAdaptivePresentationControllerDelegate, UIGestureRecognizerDelegate {
   
    
   
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        print("Did Dismiss")
        if cancelTimer != nil {
            cancelTimer!.invalidate()
            cancelTimer = nil
        }
        SwiftEntryKit.dismiss()
        startSceneView(finish: "end")
    }
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        print("Start Dismiss")
        hasStartedDismissing = true
        startSceneView(finish: "start")
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
            case "goToFullScreen":
                print("full screen")
                default:
                    print("default, something wrong")
            }
            
            
        }
    func toClassic() {
        print("classicmode")
        self.scanModeToggle = .classic
        self.stopProcessingImage = false
        self.classicTimer.resume()
        self.enableAutoCoaching()
        self.blurScreen(mode: "classic")
        //self.fastTimer.suspend()
        self.newFastModeTimer?.invalidate()
        self.focusTimer.suspend()
        
    }
    func toFocus() {
        self.scanModeToggle = .focused
        //self.fastTimer.suspend()
        self.newFastModeTimer?.invalidate()
        self.classicTimer.suspend()
        self.classicHasFoundOne = false
        print("focus")
        self.stopCoaching()
        self.stopProcessingImage = true
        self.focusTimer.resume()
        self.blurScreen(mode: "focus")
    }
    func toFast() {
        
        self.scanModeToggle = .fast
        self.classicHasFoundOne = false
        self.stopCoaching()
        self.stopProcessingImage = true
        self.classicTimer.suspend()
        self.focusTimer.suspend()
        self.blurScreen(mode: "fast")
        //self.fastTimer.resume()
        newFastModeTimer = Timer.scheduledTimer(withTimeInterval: newFastUpdateInterval, repeats: true) { [weak self] _ in
            guard !self!.busyFastFinding else { return }
            if let capturedImage = self?.sceneView.session.currentFrame?.capturedImage {
                self?.fastFind(in: capturedImage)
            }
        }
        //self.modeButton.close()
    }
    @objc func tappedOnce(gr:UITapGestureRecognizer) {
        // do something here
        print("akjd")
        let loc: CGPoint = gr.location(in: gr.view)
        refreshScreen(location: loc)
    }
    func setUpButtons() {
//        let recognizerView = UIView()
//        view.insertSubview(recognizerView, aboveSubview: sceneView)
//        recognizerView.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//        }
//        recognizerView.isUserInteractionEnabled = true
        //recognizerView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedOnce))
        tap.numberOfTapsRequired = 1
        tap.delegate = self
        
        //recognizerView.addGestureRecognizer(tap)
        //print(sceneView.isUserInteractionEnabled)
        //sceneView.isUserInteractionEnabled = true
        view.addGestureRecognizer(tap)
        view.bringSubviewToFront(numberLabel)
//        self.statusBarHidden = true
//        UIView.animate(withDuration: 0.3, animations: {
//            self.setNeedsStatusBarAppearanceUpdate()
//        })
        
       // modeButton.buttonAnimationConfiguration = .transition(toImage: #imageLiteral(resourceName: "X Button Action"))
        
//        let goToHist = menuButton.addItem()
//        goToHist.titleLabel.text = "History"
//        goToHist.imageView.image = #imageLiteral(resourceName: "bhistory 2")
//        goToHist.action = { item in
//            print("hist")
//            //self.performSegue(withIdentifier: "goToHistory", sender: self)
//            self.present(PhotoCollectionViewController(), animated: true, completion: nil)
//            //self.t.suspend()
//            //self.f.suspend()
//        }
       
        
        let goToSett = menuButton.addItem()
        goToSett.tag = 12462
        goToSett.titleLabel.text = "Settings"
        goToSett.imageView.image = #imageLiteral(resourceName: "bsettings 2")
        goToSett.action = { item in
            print("settings")
            
            self.blurScreenForSheetPresentation()
            
            self.performSegue(withIdentifier: "goToSettings", sender: self)
            //self.t.suspend()
            //self.f.suspend()
        }
        let goToNewHistory = menuButton.addItem()
        goToNewHistory.tag = 12461
        goToNewHistory.titleLabel.text = "Newer History"
        goToNewHistory.imageView.image = #imageLiteral(resourceName: "bhistory 2")
        goToNewHistory.action = { item in
            self.blurScreenForSheetPresentation()
            self.performSegue(withIdentifier: "goToNewHistory", sender: self)
        }
//        let goToNewHist = menuButton.addItem()
//        goToNewHist.titleLabel.text = "New History"
//        goToNewHist.imageView.image = #imageLiteral(resourceName: "bhistory 2")
//        goToNewHist.action = { item in
//             print("new history")
//            //self.performSegue(withIdentifier: "goToNewHistory", sender: self)
//            //presentViewController(PinnedSectionHeaderFooterViewController, animated: true, completion: nil)
//
//            //self.present(PinnedSectionHeaderFooterViewController(), animated: true, completion: nil)
//
//
//        }
        
//        let goToFast = modeButton.addItem()
//        goToFast.titlePosition = .trailing
//        goToFast.titleLabel.text = "Fast mode"
//        goToFast.imageView.image = #imageLiteral(resourceName: "bfast 2")
//        goToFast.action = { item in
//            self.toFast()
//        }
//        
//        let goToClassic = modeButton.addItem()
//        goToClassic.titlePosition = .trailing
//        goToClassic.titleLabel.text = "Classic mode"
//        goToClassic.imageView.image = #imageLiteral(resourceName: "bclassic 2")
//        goToClassic.action = { item in
//            self.toClassic()
//        }
//        let goToFocus = modeButton.addItem()
//        goToFocus.titlePosition = .trailing
//        goToFocus.titleLabel.text = "Focus mode"
//        goToFocus.imageView.image = #imageLiteral(resourceName: "bfocus 2")
//        goToFocus.action = { item in
//            self.toFocus()
//        }
        menuButton.overlayView.backgroundColor = UIColor.clear
//        modeButton.overlayView.backgroundColor = UIColor.clear
    }

    
}
extension ViewController {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        //print(touch.view)
        if let histButton = view.viewWithTag(12461) {
            return false
        }
        if let settButton = view.viewWithTag(12462) {
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
