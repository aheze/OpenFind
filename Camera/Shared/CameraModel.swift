//
//  CameraModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

/// an event in the live preview event history.
struct Event {
    var date: Date
    var sentences = [FastSentence]()
    var highlights = [Highlight]()
}

struct PausedImage: Identifiable {
    let id = UUID()
    var cgImage: CGImage?
    var dateScanned: Date?
    var sentences = [Sentence]()

    /// if it's saved to Photos, set this.
    var assetIdentifier: String?
}

enum SnapshotState {
    case inactive
    case startedSaving
    case noImageYet /// no image yet, call the save function once the image is gotten.
    case saved
}


enum ToolbarState {
    case inTabBar
    case sideCompact /// horizontal iPhone, double row of buttons
    case sideExpanded /// iPad
}
