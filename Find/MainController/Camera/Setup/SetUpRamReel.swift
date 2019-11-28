//
//  SetUpRamReel.swift
//  Find
//
//  Created by Andrew on 11/11/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

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
        //print(ramReel.collectionView.frame)
        ramReel.collectionView.isHidden = false
        darkBlurEffectHeightConstraint.constant = self.view.bounds.size.height
        
        self.toolbarView.isHidden = false
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            //print(self.keyboardHeight)
            self.toolbarView.alpha = 1
            self.toolbarBottomConstraint.constant = self.keyboardHeight
            self.darkBlurEffect.alpha = 1
            if self.scanModeToggle == .focused {
            if let tag1 = self.view.viewWithTag(1) {
                tag1.alpha = 0
            }
            if let tag2 = self.view.viewWithTag(2) {
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
                tag1.alpha = 1
            }
            if let tag2 = self.view.viewWithTag(2) {
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
