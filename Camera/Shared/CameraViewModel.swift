//
//  CameraViewModel.swift
//  Camera  //
//  Created by Zheng on 12/2/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import CoreMotion
import SwiftUI

class CameraViewModel: ObservableObject {
    @Published var resultsCount = 0
    @Published var showingMessageView = false
    
    @Published var highlights = [Highlight]()
    
    @Published var snapshotState = SnapshotState.inactive
 
    /// shutter on/off
    @Published var shutterOn = false
    @Published var pausedImage: PausedImage?
    
    @Published var flash = false
    @Published var cacheOn = false
    
    /// press the snapshot/camera button
    var snapshotPressed: (() -> Void)?
    var shutterPressed: (() -> Void)?
    var settingsPressed: (() -> Void)?
    init() {}
    
    var recentEvents = [Event]()
    
    /// set to false if no results for a long time, to conserve battery and other system resources
    var livePreviewScanning = true
    
    /// detect motion to resume live preview
    var motionManager: CMMotionManager?
    
    func resume() {
        withAnimation {
            snapshotState = .inactive
        }
        pausedImage = nil
    }
    
    func setSnapshotState(to state: SnapshotState) {
        withAnimation {
            snapshotState = state
        }
    }
}
