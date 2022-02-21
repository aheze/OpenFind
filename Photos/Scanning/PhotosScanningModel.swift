//
//  PhotosScanningModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/20/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

class PhotosScanningModel: ObservableObject {
    enum ScanningState {
        case dormant
        case scanning
    }
    
    var state = ScanningState.dormant
    var photosToScan = [Photo]()
    var currentScanningPhoto: Photo?
    
    /// pass back sentences
    var photoScanned: ((Photo, [Sentence]) -> Void)?
    
    @Published var scannedPhotosCount = 0
    @Published var totalPhotosCount = 0
    
    @Saved(Defaults.scanOnLaunch.0) var scanOnLaunch = Defaults.scanOnLaunch.1
    @Saved(Defaults.scanInBackground.0) var scanInBackground = Defaults.scanInBackground.1
    @Saved(Defaults.scanWhileCharging.0) var scanWhileCharging = Defaults.scanWhileCharging.1
    
    func loadScanning() {}
    
    func resumeScanning() {
        state = .scanning
    }
    
    func pauseScanning() {
        state = .dormant
    }
    
    func scanPhoto(_ photo: Photo) {
        if let metadata = photo.metadata {
            
        } else {
            let metadata = PhotoMetadata()
        }
    }
    
    /// true if done scanning / or should stop
    func shouldResumeScanning() -> Bool {
        if state == .scanning {
            return true
        }
        if !photosToScan.isEmpty {
            return true
        }
        return false
    }
}
