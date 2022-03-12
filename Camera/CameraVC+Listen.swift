//
//  CameraVC+Listen.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

extension CameraViewController {
    func listenToModel() {
        /// Listen to shutter press events
        model.shutterPressed = { [weak self] in
            guard let self = self else { return }
            
            if self.model.shutterOn {
                self.pause()
            } else {
                self.resume()
                self.model.resume() /// reset the image back to `nil`
            }
        }
        
        model.snapshotPressed = { [weak self] in
            guard let self = self else { return }
            self.snapshot()
        }
        
        tabViewModel.animatorProgressChanged = { [weak self] progress in
            guard let self = self else { return }
            self.updateBlurProgress(to: progress)
        }
    }
}
