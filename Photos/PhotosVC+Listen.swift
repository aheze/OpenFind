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
        
        searchViewModel.fieldsChanged = { [weak self] textChanged in
            guard let self = self else { return }
            
            if textChanged {
                self.find()
            } else {
                /// replace all highlights
                self.updateHighlightColors()
            }
            
            let strings = self.searchViewModel.stringToGradients.keys
            if strings.isEmpty {
                self.showResults(false)
            } else {
                self.showResults(true)
            }
        }
       
    }
}
