//
//  CameraViewModel.swift
//  Camera  //
//  Created by Zheng on 12/2/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import Combine
import CoreMotion
import SwiftUI

class CameraViewModel: ObservableObject {
    @Published var actualResultsCount = 0
    
    /// this will be slightly delayed/debounced
    @Published var displayedResultsCount = 0
    @Published var showingMessageView = false
    
    @Published var snapshotState = SnapshotState.inactive
 
    @Published var resultsOn = false
    /// shutter on/off
    @Published var shutterOn = false
    @Published var pausedImage: PausedImage?
    
    @Published var flash = false
    @Published var cacheOn = false
    
    var resultsPressed: (() -> Void)?
    var snapshotPressed: (() -> Void)? /// press the snapshot/camera button
    var flashPressed: (() -> Void)?
    var shutterPressed: (() -> Void)?
    var settingsPressed: (() -> Void)?
    
    /// from the status view
    var rescan: (() -> Void)?
    
    /// keep scanning after tapping the status view
    var resumeScanning: (() -> Void)?
    
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
    
    var resultsCountCancellable: AnyCancellable?
    
    init() {
        resultsCountCancellable = $actualResultsCount
            .throttle(for: .seconds(CameraConstants.resultsCountUpdateDuration), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] resultsCount in
                self?.displayedResultsCount = resultsCount
            }
    }
}
