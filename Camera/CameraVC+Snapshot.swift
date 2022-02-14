//
//  CameraVC+Snapshot.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

extension CameraViewController {
    func snapshot() {
        if !model.snapshotSaved {
            model.snapshotSaved = true
            print("Saving!")
            if let currentImage = model.pausedImage {
                let image = UIImage(cgImage: currentImage)
                print("Current image exists.")
            }
        }
    }
}
