//
//  CameraVC+Events.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

extension CameraViewController {
    func createLivePreviewEvent(sentences: [FastSentence], highlights: Set<Highlight>) {
        let event = Event(date: Date(), sentences: sentences, highlights: highlights)

        model.recentEvents.append(event)
        if model.recentEvents.count > CameraConstants.maximumHistoryCount {
            _ = model.recentEvents.removeFirst()
        }
    }
    
    func checkEvents() {
        if model.recentEvents.count >= CameraConstants.maximumHistoryCount {
            checkDormant()
        }
    }
    
    func checkDormant() {
        let recentEvents = model.recentEvents.suffix(25)
        let recentRecognizedStrings = recentEvents.map { $0.sentences }.flatMap { $0 }.map { $0.string } as [String]
        let recentFoundHighlights = recentEvents.map { $0.highlights }.flatMap { $0 }.map { $0.string } as [String]
        
//        if recentFoundHighlights.count == 0, recentRecognizedStrings.count <= 20 {
//            model.recentEvents.removeAll()
//            
//            /// stop scanning for now, until the phone shakes
//            stopLivePreviewScanning()
//        }
    }
}
