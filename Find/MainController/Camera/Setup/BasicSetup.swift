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
    case fast
}

//MARK: Set Up the floating buttons, classic timer

extension ViewController {
    
//    func setUpCrosshair() {
//        let middle = view.bounds.width / 2
//        let yCoord : CGFloat = 265
//        let rect1 = CGRect(x: middle - 1.5, y: yCoord - 12.5, width: 3, height: 25)
//        let rect2 = CGRect(x: middle - 12.5, y: yCoord - 1.5, width: 25, height: 3)
//        let crosshair1 = UIView(frame: rect1)
//        let crosshair2 = UIView(frame: rect2)
//        crosshair1.tag = 1
//        crosshair2.tag = 2
//        crosshairPoint = CGPoint(x: middle, y: yCoord)
//        print(yCoord)
//        crosshair1.alpha = 0
//        crosshair2.alpha = 0
//        crosshair1.backgroundColor = UIColor.gray
//        crosshair2.backgroundColor = UIColor.gray
//        view.addSubview(crosshair1)
//        view.addSubview(crosshair2)
//    }
    func setUpFilePath() {
        guard let url = URL.createFolder(folderName: "historyImages") else {
            print("no create")
            return }
        globalUrl = url
    }
//    func setUpToolBar() {
//        toolbarView.isHidden = true
//        toolbarView.alpha = 0
//        toolbarView.frame.origin.y = deviceSize.height - 40
//        print(deviceSize.height)
//    }
   
    func setUpTimers() {
//        fastTimer.eventHandler = {
//            self.fastFind()
//            if(false){
//                self.fastTimer.suspend() //keep strong reference
//            }
//        }
//        newFastModeTimer = Timer.scheduledTimer(withTimeInterval: newFastUpdateInterval, repeats: true) { [weak self] _ in
//            guard !self!.busyFastFinding else { return }
//            if let capturedImage = self?.sceneView.session.currentFrame?.capturedImage {
//                self?.fastFind(in: capturedImage)
//            }
//        }
//        classicTimer.eventHandler = {
//            if self.isBusyProcessingImage == false {
//                self.processImage()
//
//            }
//            if(false){
//                self.classicTimer.suspend()
//            }
//        }
//        focusTimer.eventHandler = {
//            if self.isLookingForRect == false {
//                //self.processImage()
//                if let pixelBuffer = self.sceneView.session.currentFrame?.capturedImage {
//                    self.search(in: pixelBuffer)
//                }
//            }
//            if(false){
//                self.focusTimer.suspend()
//            }
//        }
    }
}

