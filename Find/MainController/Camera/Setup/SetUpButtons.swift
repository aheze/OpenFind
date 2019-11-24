//
//  SetUpButtons.swift
//  Find
//
//  Created by Andrew on 11/11/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

extension ViewController {
    
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
            self.performSegue(withIdentifier: "goToHistory", sender: self)
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
