//
//  CameraViewModel.swift
//  Camera  //
//  Created by Zheng on 12/2/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import CoreMotion
import SwiftUI

struct History {
    var text = [FindText]()
    var highlights = Set<Highlight>()
}

struct HighlightsHistory {
    var history = [Set<Highlight>]()
    mutating func newHighlightsFound(_ newHighlights: Set<Highlight>) {
        history.append(newHighlights)
        print(history.count, terminator: " ")
        
        /// start checking after 60 passes
        if history.count >= 60 {
            let recentHistory = history.suffix(15)
            let recentHighlights = recentHistory.flatMap { $0 }
            
            if recentHighlights.count == 0 {
                print("No results recently.")
            }
            
            history.removeAll()
        }
    }
}

class CameraViewModel: ObservableObject {
    @Published var resultsCount = 0
    
    @Published var highlights = [Highlight]()
    
    /// If the button is on or not.
    @Published var snapshotOn = false
    
    /// If the snapshot was actually saved to the photo library
    var snapshotSaved = false
    
    /// shutter on/off
    @Published var shutterOn = false
    @Published var pausedImage: CGImage?
    var currentPausedUUID: UUID? /// prevent hiding/showing the camera feed incorrectly
    
    @Published var flash = false
    @Published var cacheOn = false
    
    /// press the snapshot/camera button
    var snapshotPressed: (() -> Void)?
    var shutterPressed: (() -> Void)?
    init() {}
    
    var highlightsHistory = HighlightsHistory()
    
    /// set to false if no results for a long time, to conserve battery and other system resources
    var livePreviewScanning = true
    
    func resume() {
        withAnimation {
            snapshotOn = false
        }
        snapshotSaved = false
        pausedImage = nil
    }
}
