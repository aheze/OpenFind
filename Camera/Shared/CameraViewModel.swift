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
    /// true if camera loaded (first frame got)
    @Published var loaded = false
    
    @Published var toolbarState = ToolbarState.inTabBar
    
    @Published var actualResultsCount = ResultsCount.noTextEntered
    
    /// this will be slightly delayed/debounced
    @Published private(set) var displayedResultsCount = ResultsCount.noTextEntered
    
    @Published var snapshotState = SnapshotState.inactive
 
    @Published var resultsOn = false
    /// shutter on/off
    @Published var shutterOn = false
    @Published var pausedImage: PausedImage?
    
    @Published var flash = false
    @Published var cacheOn = false
    
    /// called after saved to photos, notify `ViewController` which then calls `scheduleUpdate` in `PhotosViewModel`
    var photoAdded: ((Photo) -> Void)?
    
    var resultsPressed: (() -> Void)?
    var snapshotPressed: (() -> Void)? /// press the snapshot/camera button
    var flashPressed: (() -> Void)?
    var shutterPressed: (() -> Void)?
    var settingsPressed: (() -> Void)?
    
    /// from the status view
    var rescan: (() -> Void)?
    
    /// keep scanning after tapping the status view
    var resumeScanning: (() -> Void)?
    
    var history = CameraHistory()
    
    /// set to false if no results for a long time, to conserve battery and other system resources
    var livePreviewScanning = true
    
    /// detect motion to resume live preview
    var motionManager: CMMotionManager?
    
    // MARK: Focusing

    var currentFocusUUID: UUID? /// for keeping track of when to remove
    
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
