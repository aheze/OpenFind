//
//  SetUpButtons.swift
//  Find
//
//  Created by Andrew on 11/11/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit
import SwiftEntryKit

extension ViewController: UIAdaptivePresentationControllerDelegate {
   
    
   
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
        self.focusTimer.suspend()
        
    }
    func toFocus() {
        self.scanModeToggle = .focused
        //self.fastTimer.suspend()
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
        self.modeButton.close()
    }
    func setUpButtons() {
//        self.statusBarHidden = true
//        UIView.animate(withDuration: 0.3, animations: {
//            self.setNeedsStatusBarAppearanceUpdate()
//        })
        
        modeButton.buttonAnimationConfiguration = .transition(toImage: #imageLiteral(resourceName: "X Button Action"))
        
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
        
        let goToFast = modeButton.addItem()
        goToFast.titlePosition = .trailing
        goToFast.titleLabel.text = "Fast mode"
        goToFast.imageView.image = #imageLiteral(resourceName: "bfast 2")
        goToFast.action = { item in
            self.toFast()
        }
        
        let goToClassic = modeButton.addItem()
        goToClassic.titlePosition = .trailing
        goToClassic.titleLabel.text = "Classic mode"
        goToClassic.imageView.image = #imageLiteral(resourceName: "bclassic 2")
        goToClassic.action = { item in
            self.toClassic()
        }
        let goToFocus = modeButton.addItem()
        goToFocus.titlePosition = .trailing
        goToFocus.titleLabel.text = "Focus mode"
        goToFocus.imageView.image = #imageLiteral(resourceName: "bfocus 2")
        goToFocus.action = { item in
            self.toFocus()
        }
        menuButton.overlayView.backgroundColor = UIColor.clear
        modeButton.overlayView.backgroundColor = UIColor.clear
    }

    
}
