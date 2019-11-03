//
//  BasicSetup.swift
//  Find
//
//  Created by Andrew on 10/13/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

enum CurrentModeToggle {
    case classic
    case focused
}

//MARK: Set Up the floating buttons, classic timer, ramreel

extension ViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToHist" {
            print("hist")
            //let destinationVC = segue.destination as! HistoryTableViewController
           // destinationVC.folderURL = globalUrl
        } else if segue.identifier == "goToSettings" {
            print("prepareSett")
        }
        
    }
    func setUpCrosshair() {
        let middle = view.bounds.width / 2
        let yCoord : CGFloat = 265
        let rect1 = CGRect(x: middle - 1.5, y: yCoord - 12.5, width: 3, height: 25)
        let rect2 = CGRect(x: middle - 12.5, y: yCoord - 1.5, width: 25, height: 3)
        let crosshair1 = UIView(frame: rect1)
        let crosshair2 = UIView(frame: rect2)
        crosshair1.tag = 1
        crosshair2.tag = 2
        crosshairPoint = CGPoint(x: middle, y: yCoord)
        print(yCoord)
        crosshair1.alpha = 0
        crosshair2.alpha = 0
        crosshair1.backgroundColor = UIColor.gray
        crosshair2.backgroundColor = UIColor.gray
        view.addSubview(crosshair1)
        view.addSubview(crosshair2)
    }
    func setUpFilePath() {
        guard let url = URL.createFolder(folderName: "historyImages") else {
            print("no create")
            return }
        globalUrl = url
    }
    func setUpToolBar() {
        toolbarView.isHidden = true
        toolbarView.alpha = 0
        toolbarView.frame.origin.y = deviceSize.height - 40
        print(deviceSize.height)
    }
   
    func setUpTimers() {
        classicTimer.eventHandler = {
            if self.isBusyProcessingImage == false {
                self.processImage()
                
            } else {
                print("busyPROCESSINGclassic+_+_+_+_+_+")
                return
            }
            if(false){
                self.classicTimer.suspend() //keep strong reference
            }
        }
        focusTimer.eventHandler = {
            if self.isLookingForRect == false {
                //self.processImage()
                if let pixelBuffer = self.sceneView.session.currentFrame?.capturedImage {
                    self.search(in: pixelBuffer)
                }
            } else {
                print("busyPROCESSINGfocus+_+_+_+_+_+")
                return
            }
            if(false){
                self.focusTimer.suspend() //keep strong reference
            }
        }
    }
    func setUpButtons() {
        self.statusBarHidden = true
        UIView.animate(withDuration: 0.3, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        })
        
        let goToHist = menuButton.addItem()
        goToHist.titleLabel.text = "History"
        goToHist.imageView.image = #imageLiteral(resourceName: "bhistory 2")
        goToHist.action = { item in
            print("hist")
            //self.performSegue(withIdentifier: "goToHist", sender: self)
            //self.t.suspend()
            //self.f.suspend()
        }
        let goToSett = menuButton.addItem()
        goToSett.titleLabel.text = "Settings"
        goToSett.imageView.image = #imageLiteral(resourceName: "bsettings 2")
        goToSett.action = { item in
            print("settings")
            self.performSegue(withIdentifier: "goToSettings", sender: self)
            //self.t.suspend()
            //self.f.suspend()
        }
        
        
        
    let goToClassic = modeButton.addItem()
        goToClassic.titlePosition = .trailing
        goToClassic.titleLabel.text = "Classic mode"
        goToClassic.imageView.image = #imageLiteral(resourceName: "bclassic 2")
        goToClassic.action = { item in
            
            
            if self.scanModeToggle == .focused {
                print("classicmode")
                self.scanModeToggle = .classic
                self.stopProcessingImage = false
                self.classicTimer.resume()
                //self.stopFinding = true
                self.enableAutoCoaching()
                self.blurScreen(mode: false)
                self.focusTimer.suspend()
                //self.f.suspend()
                //self.stopLoopTag = false
                //self.t.resume()
            }
        }
        let goToFocus = modeButton.addItem()
        goToFocus.titlePosition = .trailing
        goToFocus.titleLabel.text = "Focus mode"
        goToFocus.imageView.image = #imageLiteral(resourceName: "bfocus 2")
        goToFocus.action = { item in
            
            
            if self.scanModeToggle == .classic {
                self.scanModeToggle = .focused
                self.classicHasFoundOne = false
                print("focus")
                self.stopCoaching()
                self.stopProcessingImage = true
                self.classicTimer.suspend()
                //self.stopLoopTag = true
                //self.stopFinding = false
                //self.t.suspend()
                //self.numberOfFocusTimes = 0
                //self.f.resume()
                self.focusTimer.resume()
                self.blurScreen(mode: true)
            }
        }
        menuButton.overlayView.backgroundColor = UIColor.clear
        modeButton.overlayView.backgroundColor = UIColor.clear
    }
}

/// Ramreel setup
extension ViewController: UICollectionViewDelegate, UITextFieldDelegate {
    func setUpRamReel() {
        dataSource = SimplePrefixQueryDataSource(data)
        var frameRect = view.bounds
        frameRect.size.height = 100
        ramReel = RAMReel(frame: frameRect, dataSource: dataSource, placeholder: "Start by typing…", attemptToDodgeKeyboard: false) {
            print("Plain:", $0)
            self.finalTextToFind = $0
            self.textDetectionRequest.customWords = [self.finalTextToFind, "Find app"]
        }
        
//        ramReel.hooks.append {
//            let r = Array($0.reversed())
//            let j = String(r)
//            print("Reversed:", j)
//        }
        
        view.addSubview(ramReel.view)
        ramReel.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        ramReel.textFieldDelegate = self as UITextFieldDelegate
        ramReel.textField.addTarget(self, action: #selector(ViewController.textFieldDidChange(_:)),
        for: UIControl.Event.editingChanged)
        
        
    }
   
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.size.height
            print("show")
        }
    }
   
    @objc func textFieldDidChange(_ textField: UITextField) {
        if ramReel.wrapper.selectedItem == nil {
        
        autocompButton.isEnabled = false
        autocompButton.alpha = 0.5
        } else {
        autocompButton.isEnabled = true
        autocompButton.alpha = 1
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        autocompButton.isEnabled = false
        autocompButton.alpha = 0.5
        ramReel.view.bounds = view.bounds
        print("textfield")
        print(ramReel.collectionView.frame)
        ramReel.collectionView.isHidden = false
        darkBlurEffectHeightConstraint.constant = self.view.bounds.size.height
        
        self.toolbarView.isHidden = false
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            print(self.keyboardHeight)
            self.toolbarView.alpha = 1
            self.toolbarBottomConstraint.constant = self.keyboardHeight
            self.darkBlurEffect.alpha = 1
            if self.scanModeToggle == .focused {
            if let tag1 = self.view.viewWithTag(1) {
                print("1")
                tag1.alpha = 0
            }
            if let tag2 = self.view.viewWithTag(2) {
                print("2")
                tag2.alpha = 0
            }
            } else {
                self.sceneView.session.pause()
                self.stopProcessingImage = true
//                self.classicTimer.suspend()
//                print("suspend timer")
            }
             self.view.layoutIfNeeded()
        }, completion: nil)
    
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        ramReel.collectionView.isHidden = true
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            var frameRect = self.view.bounds
            frameRect.size.height = 100
            self.ramReel.view.bounds = frameRect
            self.toolbarBottomConstraint.constant = 0
            self.toolbarView.alpha = 0
            
            self.darkBlurEffect.alpha = 0.7
            self.darkBlurEffectHeightConstraint.constant = 100
            
            if self.scanModeToggle == .focused {
            if let tag1 = self.view.viewWithTag(1) {
                print("1")
                tag1.alpha = 1
            }
            if let tag2 = self.view.viewWithTag(2) {
                print("2")
                tag2.alpha = 1
            }
            } else {
                self.sceneView.session.run(self.sceneConfiguration)
                self.stopProcessingImage = false
//                self.classicTimer.resume()
//                print("resume timer")
            }
            self.view.layoutIfNeeded()
        }, completion: {_ in
            self.toolbarView.isHidden = true
            self.view.bringSubviewToFront(self.matchesBig)
        }
        )
             print(ramReel.selectedItem)
//        if ramReel.selectedItem == "" {
//            ramReel.placeholder = "Type here to find!"
//        }
        finalTextToFind = ramReel.selectedItem ?? ""
        
    }
    
    
}
