//
//  NotifyTransition.swift
//  Find
//
//  Created by Zheng on 1/7/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension ViewController {
    func notifyCompletion(finishedAtVC currentVC: UIViewController, animatedToCamera: Bool = true) {
        print("notifying")
        switch currentVC {
        case is PhotosWrapperController:
            print("ended at photos")
            startCameraShutoff()
            
            ConstantVars.shouldHaveLightStatusBar = false
        case is CameraViewController:
            print("ended at camera")
            startCamera()
            ConstantVars.shouldHaveLightStatusBar = true
            
            if TipViews.currentLocalStep == 1 {
                startLocalSecondStep()
            }
            
            camera.enableButtons(true)
            
            if animatedToCamera {
                print("Animated to camera, hide shutter")
                tabBarView.cameraContainerView.alpha = 0
                tabBarView.hideRealShutter?(false)
            }
            
            UIAccessibility.post(notification: .screenChanged, argument: camera.cameraIconHolder)
            
        case is ListsNavController:
            print("ended at lists")
            startCameraShutoff()
            
            ConstantVars.shouldHaveLightStatusBar = false
        default:
            print("Unknown notified VC")
        }
        
        UIView.animate(withDuration: 0.3) {
            self.updateStatusBar()
        }
    }
}
