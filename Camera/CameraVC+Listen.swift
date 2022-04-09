//
//  CameraVC+Listen.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import SwiftUI

extension CameraViewController {
    func listenToModel() {
        model.flashPressed = { [weak self] in
            guard let self = self else { return }
            self.toggleFlashlight(self.model.flash)
        }
        
        model.resultsPressed = { [weak self] in
            guard let self = self else { return }
            
            if self.model.resultsOn {
                self.presentStatusView()
            } else {
                self.hideStatusView()
            }
        }
        
        /// Listen to shutter press events
        model.shutterPressed = { [weak self] in
            guard let self = self else { return }
            
            if self.model.shutterOn {
                self.pause()
                if self.model.flash {
                    self.toggleFlashlight(false)
                }
            } else {
                self.resume()
                self.model.resume() /// reset the image back to `nil`
                if self.model.flash {
                    self.toggleFlashlight(true)
                }
            }
        }
        
        /// rescan from indicator
        model.rescan = { [weak self] in
            guard let self = self else { return }
            
            guard
                !self.progressViewModel.percentageShowing,
                let image = self.model.pausedImage,
                let cgImage = image.cgImage
            else { return }
            
            self.startAutoProgress()
            Task {
                await self.scan(currentUUID: image.id, cgImage: cgImage)
                self.endAutoProgress()
            }
        }
        
        model.resumeScanning = { [weak self] in
            guard let self = self else { return }
            self.resumeLivePreviewScanning()
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
