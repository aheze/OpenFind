//
//  CameraViewModel.swift
//  Camera
//
//  Created by Zheng on 12/2/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

class CameraViewModel: ObservableObject {
    @Published var resultsCount = 0
    
    /// set to true when tapped, then set back to false 1 second later
    /// when paused, don't set it back until unpaused
    @Published var snapshotSaved = false
    
    /// shutter on/off
    @Published var shutterOn = false {
        didSet {
//            withAnimation(.spring()) {
//                snapshotSaved = false
//            }
        }
    }
    
    
    @Published var flash = false
    @Published var cacheOn = false
    
    /// press the snapshot/camera button
    var snapshotPressed: (() -> Void)?
    var shutterPressed: (() -> Void)?
    init() { }
}
