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
    var sentences = [Sentence]()
    var highlights = Set<Highlight>()
}

struct PausedImage: Identifiable {
    let id = UUID()
    var cgImage: CGImage?
    var scanned = false
    var sentences = [Sentence]()

    /// if it's saved to Photos, set this.
    var assetIdentifier: String?
}

enum SnapshotState {
    case inactive
    case startedSaving
    case noImageYet /// no image yet, call the save function once the image is gotten.
    case saved

    /// snapshot button pressed, start saving.
//    var snapshotStartedSaving = false

    /// If the snapshot has been saved. If this is true, make the button blue.
//    var snapshotSaved = false
}
