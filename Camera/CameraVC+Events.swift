//
//  CameraVC+Events.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

extension CameraViewController {
    func createLivePreviewEvent(sentences: [FastSentence], highlights: [Highlight]) {
        let now = Date()
        model.history.dateLastScanned = now
        let event = Event(date: now, sentences: sentences, highlights: highlights)

        model.history.recentEvents.append(event)
        if model.history.recentEvents.count > CameraConstants.maximumHistoryCount {
            _ = model.history.recentEvents.removeFirst()
        }
    }
    
    func shouldScan() -> Bool {
        if let dateLastScanned = model.history.dateLastScanned {
            if let duration = Settings.Values.ScanningFrequencyLevel(rawValue: realmModel.cameraScanningFrequency)?.getDouble() {
                let difference = dateLastScanned.distance(to: Date())
                return difference > duration
            } else {
                return true
            }
        } else {
            return true
        }
        
    }
    
    func checkEvents() {
        if model.history.recentEvents.count >= CameraConstants.maximumHistoryCount {
            if !model.resultsOn {
                checkDormant()
            }
        }
    }
    
    func checkDormant() {
        let recentEvents = model.history.recentEvents.suffix(30)
        
        let recentRecognizedStrings = recentEvents.map { $0.sentences }.flatMap { $0 }.map { $0.string } as [String]
        let recentFoundHighlights = recentEvents.map { $0.highlights }.flatMap { $0 }.map { $0.string } as [String]
        
        if recentFoundHighlights.count == 0, recentRecognizedStrings.count <= 20 {
            model.history.recentEvents.removeAll()
            
            /// stop scanning for now, until the phone shakes
            stopLivePreviewScanning()
        }
    }
}
