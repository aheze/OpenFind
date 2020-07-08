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
        if cancelTimer != nil {
            cancelTimer!.invalidate()
            cancelTimer = nil
        }
        
        readDefaultsValues()
        
        SwiftEntryKit.dismiss()
        sortSearchTerms()
        startVideo()
        loadListsRealm()
        injectListDelegate?.resetWithLists(lists: editableListCategories)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
            stopSession()
            switch segue.identifier {
            case "goToSettings":
                print("prepare settings")
                segue.destination.presentationController?.delegate = self
                let destinationVC = segue.destination as! SettingsViewController
                destinationVC.folderURL = globalUrl
                destinationVC.modalPresentationCapturesStatusBarAppearance = true
            case "goToNewHistory":
                segue.destination.presentationController?.delegate = self
                let destinationVC = segue.destination as! NewHistoryViewController
                destinationVC.folderURL = globalUrl
                destinationVC.highlightColor = highlightColor
                destinationVC.modalPresentationCapturesStatusBarAppearance = true
            case "goToLists" :
                let destinationVC = segue.destination as! ListController
                destinationVC.modalPresentationCapturesStatusBarAppearance = true
                segue.destination.presentationController?.delegate = self
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
        newImageView.frame = frameRect
        newImageView.contentMode = .scaleAspectFit
        cameraView.addSubview(newImageView)
        newImageView.alpha = 0
        newImageView.transform = CGAffineTransform(scaleX: 1.35, y: 1.35)
        
        UIView.animateKeyframes(withDuration: 0.6, delay: 0, options: .calculationModeCubic, animations: {
                        UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.25) {
                            newImageView.alpha = 1
                            newImageView.transform = CGAffineTransform.identity
                        }

                        UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.25) {
                            newImageView.alpha = 0.8
                        }

                        UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.25) {
                            newImageView.alpha = 1
                        }

                        UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25) {
                            newImageView.alpha = 0
                        }
                    }, completion: { _ in
                        newImageView.removeFromSuperview()
                    })
        
        if let device = cameraDevice {
            do {
                try device.lockForConfiguration()

                device.focusPointOfInterest = focusPoint
                device.focusMode = .autoFocus
                device.exposurePointOfInterest = focusPoint
                device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
                device.unlockForConfiguration()
            }
            catch {
                // just ignore
            }
            
            
        }
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
        let histImage = UIImage(systemName: "photo.fill.on.rectangle.fill", withConfiguration: symbolConfiguration)?.withTintColor(UIColor(named: "DarkGray") ?? .black, renderingMode: .alwaysOriginal)
        let settImage = UIImage(systemName: "gear", withConfiguration: symbolConfiguration)?.withTintColor(UIColor(named: "DarkGray") ?? .black, renderingMode: .alwaysOriginal)
        
        let photos = NSLocalizedString("photos", comment: "Multipurpose def=Photos")
        let lists = NSLocalizedString("lists", comment: "Multipurpose def=Lists")
        let settings = NSLocalizedString("settings", comment: "Multipurpose def=Settings")
        
        let goToNewHistory = menuButton.addItem()
        goToNewHistory.tag = 12461
        goToNewHistory.titleLabel.text = photos
        
        
        goToNewHistory.imageView.image = histImage
        goToNewHistory.action = { item in
            self.blurScreenForSheetPresentation()
            self.performSegue(withIdentifier: "goToNewHistory", sender: self)
        }
        let goToLists = menuButton.addItem()
        goToLists.tag = 12463
        goToLists.titleLabel.text = lists
        goToLists.imageView.image = listImage
        goToLists.action = { item in
            self.blurScreenForSheetPresentation()
            self.performSegue(withIdentifier: "goToLists", sender: self)
        }
        
        let goToSett = menuButton.addItem()
        goToSett.tag = 12462
        goToSett.titleLabel.text = settings
        goToSett.imageView.image = settImage
        goToSett.action = { item in
//            print("settings")
            self.blurScreenForSheetPresentation()
            self.performSegue(withIdentifier: "goToSettings", sender: self)
        }
        
        if let xImage = UIImage(named: "jjXButton") {
            menuButton.buttonAnimationConfiguration = .transition(toImage: xImage)
            menuButton.overlayView.backgroundColor = UIColor.clear
        }
    }

    
}
extension ViewController {
    
    @objc func tappedOnStats() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let statsViewController = storyboard.instantiateViewController(withIdentifier: "StatsViewController") as! StatsViewController
        statsViewController.view.layer.cornerRadius = 10
        statsViewController.view.clipsToBounds = true
        statsViewController.edgesForExtendedLayout = []
        
        self.updateStatsNumber = statsViewController
        
        let boldAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .bold)]
        let regularAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular)]
        
        let spaceMatchesFoundCurrently = NSLocalizedString("spaceMatchesFoundCurrently", comment: "Stats def= matches found currently")
        
        let boldText = NSAttributedString(string: "\(currentNumberOfMatches)", attributes: boldAttribute)
        let regularText = NSAttributedString(string: spaceMatchesFoundCurrently, attributes: regularAttribute)
        let newString = NSMutableAttributedString()
        newString.append(boldText)
        newString.append(regularText)
        statsViewController.currentlyHowManyMatches.attributedText = newString
        
        let currentlySearchingFor = NSLocalizedString("currentlySearchingFor", comment: "Stats def=Currently searching for")
        
        if allowSearch == true {
            var wordsFinding = [String]()
            for list in stringToList.keys {
                wordsFinding.append(list)
            }
            
            var finalMatchesString = ""
            
            switch wordsFinding.count {
             case 0:
                let noWords = NSLocalizedString("noWords", comment: "Stats def=[no words]")
                finalMatchesString = noWords
             case 1:
                let quotexquote = NSLocalizedString("quote %@ quote", comment: "Stats def=\"x\"")
                let string = String.localizedStringWithFormat(quotexquote, wordsFinding[0])
                finalMatchesString = string
             case 2:
                print("MULTI 2!!!!!!!")
                let quotexquoteSpaceAndquotexquote = NSLocalizedString("quote %@ quoteSpaceAndquote %@ quote", comment: "Stats def=\"x\" and \"x\"")
                let string = String.localizedStringWithFormat(quotexquoteSpaceAndquotexquote, wordsFinding[0], wordsFinding[1])
                finalMatchesString = string
                
             default:
                for (index, message) in wordsFinding.enumerated() {
                    if index != wordsFinding.count - 1 {
                        let quotexquoteCommaSpace = NSLocalizedString("quote %@ quoteCommaSpace", comment: "Stats def=\"x\", ")
                        let string = String.localizedStringWithFormat(quotexquoteCommaSpace, message)
                        finalMatchesString.append(string)
                    } else {
                        let spaceAndSpacequotexquote = NSLocalizedString("spaceAndSpacequote %@ quote", comment: "Stats def= and \"x\"")
                        let string = String.localizedStringWithFormat(spaceAndSpacequotexquote, message)
                        finalMatchesString.append(string)
                    }
                }
             }
            
            let thisWordColon = NSLocalizedString("thisWord", comment: "Stats def=this word")
            let theseWordsColon = NSLocalizedString("theseWords", comment: "Stats def=these words")
            
            
            var thisWord = thisWordColon
            if wordsFinding.count != 1 {
                thisWord = theseWordsColon
            }
            
            let regularMatchesText = NSAttributedString(string: "\(currentlySearchingFor) \(thisWord): ", attributes: regularAttribute)
            let boldMatchesText = NSAttributedString(string: finalMatchesString, attributes: boldAttribute)
            
            let newMatches = NSMutableAttributedString()
            newMatches.append(regularMatchesText)
            newMatches.append(boldMatchesText)
            statsViewController.currentSearchingForTheseWords.attributedText = newMatches
            
        } else {
            let regularMatchesText = NSAttributedString(string: "\(currentlySearchingFor): ", attributes: regularAttribute)
            let nothingHaveDuplicatesPaused = NSLocalizedString("nothingHaveDuplicatesPaused", comment: "Stats def=Nothing! You have duplicates, so Find is currently paused. Make sure that there are no duplicates in the Search Bar.")
            
            let boldMatchesText = NSAttributedString(string: nothingHaveDuplicatesPaused, attributes: boldAttribute)
            
            let newMatches = NSMutableAttributedString()
            newMatches.append(regularMatchesText)
            newMatches.append(boldMatchesText)
            statsViewController.currentSearchingForTheseWords.attributedText = newMatches
        }
    
        
        var attributes = EKAttributes.centerFloat
        attributes.displayDuration = .infinity
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .easeOut)
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
        attributes.screenBackground = .color(color: EKColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3802521008)))
        attributes.entryBackground = .color(color: .white)
        attributes.screenInteraction = .absorbTouches
        attributes.positionConstraints.size.height = .constant(value: screenBounds.size.height - CGFloat(100))
        attributes.positionConstraints.maxSize = .init(width: .constant(value: 600), height: .constant(value: 800))
        attributes.statusBar = .hidden
        SwiftEntryKit.display(entry: statsViewController, using: attributes)
        
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
            return true
        default:
            return false
        }
        
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
        }
        return true
    }
}
