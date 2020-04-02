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
//        print("Did Dismissss")
        if cancelTimer != nil {
            cancelTimer!.invalidate()
            cancelTimer = nil
        }
        
        readDefaultsValues()
        
        SwiftEntryKit.dismiss()
//        currentMatchStrings.append(newSearchTextField.text ?? "")
        sortSearchTerms()
        startVideo(finish: "end")
        loadListsRealm()
        injectListDelegate?.resetWithLists(lists: editableListCategories)
       // listsCollectionView.reloadData()
//        loadListsRealm()
//        updateToolbar
    }
//    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
//        print("Start Dismiss")
////        hasStartedDismissing = true
//        startVideo(finish: "start")
////        if cancelTimer == nil {
////        cancelTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
////        }
//    }
//    @objc func updateTimer() {
//        cancelSeconds += 1
//        if cancelSeconds == 5 {
//            print("hit 5 secs")
//            if cancelTimer != nil {
//                cancelTimer!.invalidate()
//                cancelTimer = nil
//            }
//            cancelSeconds = 0
//            cancelSceneView()
//        }
//
//        //This will decrement(count down)the seconds.
//        //timerLabel.text = "\(seconds)"
//    }
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
        
//            currentMatchStrings.removeAll()
            stopSession()
            switch segue.identifier {
            case "goToSettings":
                print("prepare settings")
                segue.destination.presentationController?.delegate = self
                let destinationVC = segue.destination as! SettingsViewController
                destinationVC.folderURL = globalUrl
            case "goToNewHistory":
                segue.destination.presentationController?.delegate = self
                let destinationVC = segue.destination as! NewHistoryViewController
                destinationVC.folderURL = globalUrl
                destinationVC.highlightColor = highlightColor
                //destinationVC.modalPresentationStyle = .fullScreen
            case "goToLists" :
                segue.destination.presentationController?.delegate = self
            case "goToFullScreen":
                print("full screen")
                default:
                    print("default, something wrong")
            }
        
            tempResetLists()
            
            
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

        let newImageView = UIImageView()
        newImageView.image = UIImage(named: "FocusRectCamera")
        let frameRect = CGRect(x: loc.x - 35, y: loc.y - 35, width: 70, height: 70)
//        print(frameRect)
        newImageView.frame = frameRect
        newImageView.contentMode = .scaleAspectFit
        cameraView.addSubview(newImageView)
        newImageView.alpha = 0
        newImageView.transform = CGAffineTransform(scaleX: 1.35, y: 1.35)
        
        UIView.animateKeyframes(withDuration: 0.6, delay: 0, options: .calculationModeCubic, animations: {
                        UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.25) {
                            newImageView.alpha = 1
                            newImageView.transform = CGAffineTransform.identity
//                            print("ANIMATE KEY")
        //                    self.imageView.transform = CGAffineTransform(scaleX: 2, y: 2)
                        }

                        UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.25) {
                            newImageView.alpha = 0.8
        //                    self.imageView.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.maxY)
                        }

                        UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.25) {
                            newImageView.alpha = 1
        //                    self.imageView.center = CGPoint(x: self.view.bounds.width, y: start.y)
                        }

                        UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25) {
                            newImageView.alpha = 0
        //                    self.imageView.center = start
                        }
                    }, completion: { _ in
                        newImageView.removeFromSuperview()
                    })
        
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
        
        
        let tapOnStats = UITapGestureRecognizer(target: self, action: #selector(tappedOnStats))
        tap.numberOfTapsRequired = 1
        tap.delegate = self
        statusView.addGestureRecognizer(tapOnStats)
        
        view.addGestureRecognizer(tap)
        view.bringSubviewToFront(numberLabel)
        
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 55, weight: .semibold)
        let listImage = UIImage(systemName: "square.grid.2x2.fill", withConfiguration: symbolConfiguration)?.withTintColor(UIColor(named: "DarkGray") ?? .black, renderingMode: .alwaysOriginal)
        let histImage = UIImage(systemName: "arrow.counterclockwise.circle.fill", withConfiguration: symbolConfiguration)?.withTintColor(UIColor(named: "DarkGray") ?? .black, renderingMode: .alwaysOriginal)
        let settImage = UIImage(systemName: "gear", withConfiguration: symbolConfiguration)?.withTintColor(UIColor(named: "DarkGray") ?? .black, renderingMode: .alwaysOriginal)
        
        
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
        
        let goToSett = menuButton.addItem()
        goToSett.tag = 12462
        goToSett.titleLabel.text = "Settings"
        goToSett.imageView.image = settImage
        goToSett.action = { item in
//            print("settings")
            self.blurScreenForSheetPresentation()
            self.performSegue(withIdentifier: "goToSettings", sender: self)
        }
        
        menuButton.overlayView.backgroundColor = UIColor.clear
    }

    
}
extension ViewController {
    
    @objc func tappedOnStats() {
        print("STTATS!!!")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let cacheController = storyboard.instantiateViewController(withIdentifier: "StatsViewController") as! StatsViewController
        cacheController.view.layer.cornerRadius = 10
        //        view.layer.cornerRadius = 10
        cacheController.view.clipsToBounds = true
        cacheController.edgesForExtendedLayout = []
        
        self.updateStatsNumber = cacheController
        
        let boldAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .bold)]
        let regularAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular)]
        
        let boldText = NSAttributedString(string: "\(currentNumberOfMatches)", attributes: boldAttribute)
        let regularText = NSAttributedString(string: " matches found currently", attributes: regularAttribute)
        let newString = NSMutableAttributedString()
        newString.append(boldText)
        newString.append(regularText)
        cacheController.currentlyHowManyMatches.attributedText = newString
        
        var wordsFinding = [String]()
        for list in stringToList.keys {
            wordsFinding.append(list)
        }
        
        var finalMatchesString = ""
        
        switch wordsFinding.count {
         case 0:
            finalMatchesString = "[no words]"
         case 1:
            finalMatchesString = "\"\(wordsFinding[0])\""
         case 2:
            finalMatchesString = "\"\(wordsFinding[0])\" and \"\(wordsFinding[1])\""
         default:
            for (index, message) in wordsFinding.enumerated() {
                if index != wordsFinding.count - 1 {
                    finalMatchesString.append("\"\(message)\", ")
                } else {
                    finalMatchesString.append(" and \"\(message)\"")
                }
            }
         }
        
        var wordsThis = "these"
        var wordS = "s"
        if wordsFinding.count == 1 { wordsThis = "this"; wordS = "" }
        
        let regularMatchesText = NSAttributedString(string: "Currently searching for \(wordsThis) word\(wordS): ", attributes: regularAttribute)
        let boldMatchesText = NSAttributedString(string: finalMatchesString, attributes: boldAttribute)
        
        let newMatches = NSMutableAttributedString()
        newMatches.append(regularMatchesText)
        newMatches.append(boldMatchesText)
        cacheController.currentSearchingForTheseWords.attributedText = newMatches
        
        var attributes = EKAttributes.centerFloat
        attributes.displayDuration = .infinity
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .easeOut)
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
        attributes.screenBackground = .color(color: EKColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3802521008)))
        attributes.entryBackground = .color(color: .white)
        attributes.screenInteraction = .absorbTouches
        attributes.positionConstraints.size.height = .constant(value: UIScreen.main.bounds.size.height - CGFloat(100))
        
        SwiftEntryKit.display(entry: cacheController, using: attributes)
        
    }
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
        case controlsView, cameraView, stackAllowView, menuAllowView, middleAllowView, statusAllowView:
//            print("Special view")
            return true
        default:
//            print("Not")
            return false
        }
        //return touch.view == gestureRecognizer.view
        
    }
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == pinchGesture {
            searchContentView.isHidden = false
            controlsView.isHidden = false
            UIView.animate(withDuration: 0.4, animations: {
                self.searchContentView.alpha = 1
                self.controlsView.alpha = 1
                self.controlsBlurView.alpha = 0
                self.controlsBlurView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            }) { _ in
                self.controlsBlurView.isHidden = true
            }
//            print("EQUALS")
        }
//        print("BEGIN")
        return true
    }
}
