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
        case is PhotosNavController:
            print("ended at photos")
        case is CameraViewController:
            print("ended at camera")
        case is ListsNavController:
            print("ended at lists")
        default:
            print("Unknown notified VC")
        }
    }
}
