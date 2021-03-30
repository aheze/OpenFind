//
//  SlideVC+Accessibility.swift
//  Find
//
//  Created by Zheng on 3/30/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension SlideViewController {
    func setupAccessibility() {
        setupDrawingView()
    }
    func setupDrawingView() {
        
        drawingBaseView.isAccessibilityElement = true
        drawingBaseView.accessibilityLabel = "Photo"
        
        drawingBaseView.activated = { [weak self] in
            guard let self = self else { return false }
            
            self.showingTranscripts.toggle()
            if self.showingTranscripts {
                self.showTranscripts()
            } else {
                self.showHighlights()
            }
            return true
        }
        
        if
            let model = self.resultPhoto.findPhoto.editableModel,
            model.isDeepSearched
        {
            drawingBaseView.accessibilityHint = "Double-tap to show transcript overlay."
        } else {
            drawingBaseView.accessibilityHint = "Cache photo to generate transcript."
        }
    }
}
