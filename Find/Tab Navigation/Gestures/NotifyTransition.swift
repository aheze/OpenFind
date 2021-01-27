//
//  NotifyTransition.swift
//  Find
//
//  Created by Zheng on 1/7/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension ViewController {
    func notifyCompletion(finishedAtVC currentVC: UIViewController) {
        print("notifying")
        switch currentVC {
        case is PhotosWrapperController:
            print("ended at photos")
            startCameraShutoff()
            
            shouldHaveLightStatusBar = false
        case is CameraViewController:
            print("ended at camera")
            startCamera()
            shouldHaveLightStatusBar = true
            
            if TipViews.currentLocalStep == 1 {
                startLocalSecondStep()
            }
            
        case is ListsNavController:
            print("ended at lists")
            startCameraShutoff()
            
            shouldHaveLightStatusBar = false
        default:
            print("Unknown notified VC")
        }
        
        UIView.animate(withDuration: 0.3) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
}
