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
    
    /// check if should go dormant
    func checkEvents() {
        // MARK: check haptic feedback

        if let hapticFeedbackLevel = Settings.Values.HapticFeedbackLevel(rawValue: realmModel.cameraHapticFeedbackLevel) {
            if
                let latestEvent = model.history.recentEvents.last,
                !latestEvent.highlights.isEmpty
            {
                var recentEventsWithoutLast = model.history.recentEvents
                _ = recentEventsWithoutLast.removeLast()
                let recentFoundHighlights = recentEventsWithoutLast.suffix(10).map { $0.highlights }.flatMap { $0 }.map { $0.string } as [String]
                
                if recentFoundHighlights.count <= 2 {
                    if let style = hapticFeedbackLevel.getFeedbackStyle() {
                        let generator = UIImpactFeedbackGenerator(style: style)
                        generator.impactOccurred()
                    }
                }
            }
        }
        
        // MARK: check dormant

        guard
            let duration = Settings.Values.ScanningDurationUntilPauseLevel(rawValue: realmModel.cameraScanningDurationUntilPause),
            duration != .never,
            model.history.recentEvents.count >= CameraConstants.maximumHistoryCount,
            !model.resultsOn
        else { return }
        
        let recentEvents = model.history.recentEvents.suffix(30)
        let recentRecognizedStrings = recentEvents.map { $0.sentences }.flatMap { $0 }.map { $0.string } as [String]
        let recentFoundHighlights = recentEvents.map { $0.highlights }.flatMap { $0 }.map { $0.string } as [String]
        
        if recentFoundHighlights.count == 0, recentRecognizedStrings.count <= 20 {
            if model.history.dateNoTextRecognized == nil {
                model.history.dateNoTextRecognized = Date()
            }
        } else {
            model.history.dateNoTextRecognized = nil
        }
        
        if let dateNoTextRecognized = model.history.dateNoTextRecognized {
            let difference = dateNoTextRecognized.distance(to: Date())
            
            if difference > duration.getDouble() ?? 0 {
                /// stop scanning for now, until the phone shakes
                stopLivePreviewScanning()
                model.history.dateNoTextRecognized = nil
            }
        }
    }
}
