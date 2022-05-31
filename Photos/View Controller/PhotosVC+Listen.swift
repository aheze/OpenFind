//
//  PhotosVC+Listen.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/15/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import SwiftUI

extension PhotosViewController {
    func listen() {
        listenToDefaults()
        listenToKeyboard()
        
        /// only called at first
        model.reload = { [weak self] in
            guard let self = self else { return }
            self.finishedLoading()
        }
        
        /// call this after new external photos added, or star change
        model.reloadAfterStarChanged = { [weak self] in
            guard let self = self else { return }
            
            self.find(context: .justFindFromExistingDoNotScan)
        }
        
        model.reloadAfterExternalPhotosChanged = { [weak self] in
            guard let self = self else { return }
            
            if self.model.resultsState != nil {
                self.find(context: .findingAfterNewPhotosAdded)
            } else {
                self.updateDisplayedPhotos()
            }
        }
        
        /// underlying arrays have already been updated, reload the UI.
        model.reloadAt = { [weak self] collectionViewIndexPath, resultsCollectionViewIndex, metadata in
            guard let self = self else { return }
            if let collectionViewIndexPath = collectionViewIndexPath {
                self.update(at: collectionViewIndexPath, with: metadata)
            }
            
            if let resultsCollectionViewIndex = resultsCollectionViewIndex {
                self.updateResults(at: resultsCollectionViewIndex, with: metadata)
            }
            
            if let currentPhoto = self.model.slidesState?.currentPhoto {
                self.model.configureToolbar(for: currentPhoto)
            }
        }
        
        /// update results after note changed
        model.updateDisplayedResults = { [weak self] in
            guard let self = self else { return }
            if self.model.resultsState != nil {
                
                self.updateResultsCellSizes {
                    self.updateResults() /// make sure to call `update` later, when results dismissed
                    self.reloadVisibleCellResults()
                }
            }
        }
        
        model.getSlidesViewControllerFor = { [weak self] photo in
            guard let self = self else { return nil }
            let storyboard = UIStoryboard(name: "PhotosContent", bundle: nil)
            let viewController = storyboard.instantiateViewController(identifier: "PhotosSlidesItemViewController") { coder in
                PhotosSlidesItemViewController(
                    coder: coder,
                    model: self.model,
                    realmModel: self.realmModel,
                    findPhoto: FindPhoto(photo: photo)
                )
            }
            return viewController
        }
        
        /// called when finding from slides or new results came live when scanning results
        model.photosWithQueuedSentencesAdded = { [weak self] photos in
            guard let self = self else { return }
            Task.detached {
                await self.findAfterQueuedSentencesUpdate(in: photos)
            }
        }
        
        model.addQueuedResults = { [weak self] allFindPhotos, starredFindPhotos, screenshotsFindPhotos, queuedResultsContext in
            guard let self = self else { return }
            
            Task.detached {
                await self.applyResults(
                    allFindPhotos: allFindPhotos,
                    starredFindPhotos: starredFindPhotos,
                    screenshotsFindPhotos: screenshotsFindPhotos,
                    context: queuedResultsContext ?? .justFindFromExistingDoNotScan
                )
            }
        }
        
        model.scanningIconTapped = { [weak self] in
            guard let self = self else { return }
            self.searchViewModel.dismissKeyboard?()
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
            
            if self.searchViewModel.isEmpty {
                self.showResults(false)
            } else {
                self.showResults(true)
                if textChanged {
                    let resultsStateExisted = self.model.resultsState != nil
                    
                    let numberOfPhotos = self.model.scannedPhotosCount
                    let estimatedTime = CGFloat(numberOfPhotos) / 1500
                    
                    /// start progress bar immediately
                    Debouncer.debounce(queue: .main, delay: .seconds(0.3)) {
                        self.progressViewModel.start(progress: .auto(estimatedTime: estimatedTime))
                    }
                    
                    Debouncer.debounce(delay: .seconds(0.4), shouldRunImmediately: false) {
                        self.find(context: .findingAfterTextChange(firstTimeShowingResults: !resultsStateExisted))
                    }
                    
                } else {
                    /// replace all highlights
                    self.updateResultsHighlightColors()
                }
            }
        }
        
        /// results top header
        headerContentModel.sizeChanged = { [weak self] in
            guard let self = self else { return }
            self.resultsHeaderHeightC?.constant = self.headerContentModel.size?.height ?? 0
            self.resultsFlowLayout.invalidateLayout()
        }
        
        slidesSearchPromptViewModel.resetPressed = { [weak self] in
            guard let self = self else { return }
            self.slidesSearchViewModel.replaceInPlace(with: self.searchViewModel, notify: true)
            self.model.updateSlidesSearchCollectionView?()
        }
        
        model.reloadCollectionViewsAfterDeletion = { [weak self] in
            guard let self = self else { return }
            self.update()
            self.updateResultsCellSizes {
                self.updateResults()
            }
        }
        
        model.stopSelecting = { [weak self] in
            guard let self = self else { return }
            
            self.resetSelectingState()
        }
        
        model.sharePhotos = { [weak self] photos in
            guard let self = self else { return }
            
            let sourceRect = CGRect(
                x: self.view.bounds.width / 2,
                y: 50,
                width: 1,
                height: 1
            )
            
            self.share(photos: photos, model: self.model, sourceRect: sourceRect)
        }
    }
}
