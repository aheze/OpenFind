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
        
        /// underlying arrays have already been updated, reload the UI.
        model.reloadAt = { [weak self] collectionViewIndexPath, resultsCollectionViewIndex, slidesCollectionViewIndex, metadata in
            guard let self = self else { return }
            if let collectionViewIndexPath = collectionViewIndexPath {
                self.update(at: collectionViewIndexPath, with: metadata)
            }
            
            if let resultsCollectionViewIndex = resultsCollectionViewIndex {
                self.updateResults(at: resultsCollectionViewIndex, with: metadata)
            }
            
            if let slidesCollectionViewIndex = slidesCollectionViewIndex {
                self.model.updateSlidesAt?(slidesCollectionViewIndex, metadata)
            }
        }
        model.metadataAddedFor = { [weak self] photo in
            guard let self = self else { return }
            print("finding.")
            self.find(in: photo)
        }
        model.scanningIconTapped = { [weak self] in
            guard let self = self else { return }
            self.present(self.scanningNavigationViewController, animated: true)
        }
        
        model.updateFieldOverrides = { [weak self] fields in
            guard let self = self else { return }
            
            var newFields = self.searchViewModel.fields
            for index in newFields.indices {
                let field = self.searchViewModel.fields[index]
                if let matchingField = fields.first(where: { $0.id == field.id }) {
                    newFields[index].overrides = matchingField.overrides
                }
            }
            
            /// don't notify yet
            self.searchViewModel.updateFields(fields: newFields, notify: false)
            
            
        }
        searchViewModel.fieldsChanged = { [weak self] textChanged in
            guard let self = self else { return }
            
            if textChanged {
                self.find()
            } else {
                /// replace all highlights
                self.updateResultsHighlightColors()
            }
            
            let strings = self.searchViewModel.stringToGradients.keys
            if strings.isEmpty {
                self.showResults(false)
            } else {
                self.showResults(true)
            }
        }
        
        headerContentModel.sizeChanged = { [weak self] in
            self?.resultsFlowLayout.invalidateLayout()
        }
    }
}
