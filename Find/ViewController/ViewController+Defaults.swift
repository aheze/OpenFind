//
//  ViewController+Defaults.swift
//  Find
//
//  Created by Zheng on 1/28/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import Settings
import SupportDocs

extension ViewController {
    func readDefaults() {
        if !CameraState.isPaused {
            longPressGestureRecognizer.isEnabled = UserDefaults.standard.bool(forKey: "swipeToNavigateEnabled")
            panGestureRecognizer.isEnabled = UserDefaults.standard.bool(forKey: "swipeToNavigateEnabled")
        }
        
        DispatchQueue.main.async {
            self.camera.sortSearchTerms(removeExistingHighlights: false)
            for subView in self.camera.drawingView.subviews {
                subView.removeFromSuperview()
            }
            self.camera.drawHighlights(highlights: self.camera.currentComponents)
            
            self.photos.photoFindViewController.findBar.sortSearchTerms()
            self.photos.photoFindViewController.tableView?.reloadData()
            
            self.tabBarView.cameraIcon.updateStyle()
            self.camera.cameraIcon.updateStyle()
        }
        
        do {
            if let recognitionLanguagesData = UserDefaults.standard.data(forKey: "recognitionLanguages") {
                let recognitionLanguages = try JSONDecoder().decode([OrderedLanguage].self, from: recognitionLanguagesData)
                
                let sorted = recognitionLanguages.sorted { ($0.priority ?? 0) < ($1.priority ?? 0) }
                let strings = sorted.map { $0.language.getName().1 }
                Defaults.recognitionLanguages = strings
            }
        } catch {
            print("Error decoding: \(error)")
        }
    }
    
    /// prevent swiping, then reset to defaults
    func temporaryPreventGestures(_ prevent: Bool) {
        if prevent {
            longPressGestureRecognizer.isEnabled = false
            panGestureRecognizer.isEnabled = false
        } else {
            if !CameraState.isPaused {
                if UserDefaults.standard.bool(forKey: "swipeToNavigateEnabled") == true {
                    longPressGestureRecognizer.isEnabled = true
                    panGestureRecognizer.isEnabled = true
                }
            }
        }
    }
}
