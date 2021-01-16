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
        case is CameraViewController:
            print("ended at camera")
            startCamera()
        case is ListsNavController:
            print("ended at lists")
            startCameraShutoff()
        default:
            print("Unknown notified VC")
        }
    }
}
