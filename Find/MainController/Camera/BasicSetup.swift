//
//  BasicSetup.swift
//  Find
//
//  Created by Andrew on 10/13/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit
import RAMReel

enum CurrentModeToggle {
    case classic
    case focused
}

//MARK: Set Up the floating buttons, classic timer, ramreel
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
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {

        ramReel.view.bounds = view.bounds
        print("textfield")
        ramReel.collectionView.isHidden = false
        darkBlurEffectHeightConstraint.constant = self.view.bounds.size.height
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
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
                self.stopProcessingImage == true
//                self.classicTimer.suspend()
//                print("suspend timer")
            }
             self.view.layoutIfNeeded()
        }, completion: nil)
    
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        ramReel.collectionView.isHidden = true
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            
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
                self.stopProcessingImage == false
//                self.classicTimer.resume()
//                print("resume timer")
            }
            self.view.layoutIfNeeded()
        }, completion: nil)
             print(ramReel.selectedItem)
        if ramReel.selectedItem == "" {
            ramReel.placeholder = "Type here to find!"
        }
        finalTextToFind = ramReel.selectedItem ?? ""
        
    }
    
    
}

extension ViewController {
   
    func setUpClassicTimer() {
        classicTimer.eventHandler = {
            if self.isBusyProcessingImage == false {
                self.processImage()
            } else {
                print("busyPROCESSING+_+_+_+_+_+")
                return
            }
            if(false){
                self.classicTimer.suspend() //keep strong reference
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
            //self.performSegue(withIdentifier: "goToSett", sender: self)
            //self.t.suspend()
            //self.f.suspend()
        }
        
        
        
    let goToClassic = modeButton.addItem()
        goToClassic.titlePosition = .trailing
        goToClassic.titleLabel.text = "Classic mode"
        goToClassic.imageView.image = #imageLiteral(resourceName: "bclassic 2")
        goToClassic.action = { item in
            print("classicmode")
            
             //self.scanModeToggle = .classic
             //self.stopFinding = true
             //self.blurScreen(mode: false)
             //self.f.suspend()
             //self.stopLoopTag = false
             //self.t.resume()
            UIView.animate(withDuration: 0.2, animations: {
                if let tag1 = self.view.viewWithTag(1) {
                    tag1.alpha = 0
                }
                if let tag2 = self.view.viewWithTag(2) {
                    tag2.alpha = 0
                }
            })

        }
        let goToFocus = modeButton.addItem()
        goToFocus.titlePosition = .trailing
        goToFocus.titleLabel.text = "Focus mode"
        goToFocus.imageView.image = #imageLiteral(resourceName: "bfocus 2")
        goToFocus.action = { item in
            //self.classicHasFoundOne = false
            print("focusmode")
            //self.scanModeToggle = .focused
            //self.stopLoopTag = true
            //self.stopFinding = false
            //self.t.suspend()
            //self.numberOfFocusTimes = 0
            //self.f.resume()
            //self.blurScreen(mode: true)
        }
        menuButton.overlayView.backgroundColor = UIColor.clear
        modeButton.overlayView.backgroundColor = UIColor.clear
    }
}
