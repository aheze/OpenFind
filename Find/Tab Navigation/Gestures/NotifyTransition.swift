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

        switch currentVC {
        case is PhotosWrapperController:

            startCameraShutoff()
            
            FindConstantVars.shouldHaveLightStatusBar = false
        case is CameraViewController:

            startCamera()
            FindConstantVars.shouldHaveLightStatusBar = true
            
            if TipViews.currentLocalStep == 1 {
                startLocalSecondStep()
            } else {
                UIAccessibility.post(notification: .screenChanged, argument: camera.cameraIconHolder)
            }
            
            camera.enableButtons(true)
            
            if animatedToCamera {

                tabBarView.cameraContainerView.alpha = 0
                tabBarView.hideRealShutter?(false)
            }
            
            
        case is ListsNavController:

            startCameraShutoff()
            
            FindConstantVars.shouldHaveLightStatusBar = false
        default:
            break
        }
        
        UIView.animate(withDuration: 0.3) {
            self.updateStatusBar()
        }
    }
}
