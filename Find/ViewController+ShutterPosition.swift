//
//  ViewController+ShutterPosition.swift
//  Find
//
//  Created by Zheng on 1/26/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension ViewController {
    func getShutterButtonFrame() {
        let frame = camera.cameraIconHolder.convert(camera.cameraIconHolder.bounds, to: tabBarView)
        print("frame is: \(frame)")
        
        tabBarView.shutterIgnoreFrame = frame
    }
}
