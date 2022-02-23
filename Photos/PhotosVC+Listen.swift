//
//  PhotosVC+Listen.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/15/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import SwiftUI

extension PhotosViewController {
    func listenToModel() {
        model.reload = { [weak self] in
            guard let self = self else { return }
            self.update(animate: false)
        }
        
        model.scanningIconTapped = { [weak self] in
            guard let self = self else { return }
            self.present(self.scanningNavigationViewController, animated: true)
        }
        
        searchViewModel.fieldsChanged = { [weak self] oldValue, newValue in
            
            guard let self = self else { return }
            
            let oldText = oldValue.map { $0.value.getText() }
            let newText = newValue.map { $0.value.getText() }
            let textIsSame = oldText == newText
            

            let strings = self.searchViewModel.stringToGradients.keys
            print("Strings: \(strings)")
            
            if strings.isEmpty {
                self.showResults(false)
            } else {
                self.showResults(true)
            }
            
            if textIsSame {
                /// replace all highlights
//                self.updateHighlightColors()
            } else {
//                self.highlightsViewModel.setUpToDate(false)
//
//                /// animate the highlight frames instead
//                if
//                    self.model.shutterOn,
//                    let image = self.model.pausedImage
//                {
//                    self.findAndAddHighlights(image: image, replace: true) { _ in
//                        self.highlightsViewModel.setUpToDate(true)
//                    }
//                }
            }
        }
    }
}
