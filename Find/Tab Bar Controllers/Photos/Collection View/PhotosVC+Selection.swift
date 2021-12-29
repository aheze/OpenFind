//
//  PhotosVC+Selection.swift
//  Find
//
//  Created by Zheng on 1/8/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

enum ChangeActions {
    case shouldStar
    case shouldNotStar
    case shouldCache
    case shouldNotCache
    case currentlyCaching
}

extension PhotosViewController {
    func selectPressed() {
        if allPhotosToDisplay.count == 0 {

            if TipViews.inTutorial {
                TipViews.finishTutorial()
            }
        } else {
            selectButtonSelected.toggle()
            showSelectionControls?(selectButtonSelected)
            
            if selectButtonSelected {
                selectButton.title = NSLocalizedString("cancel", comment: "Multipurpose def=Cancel")
                collectionView.allowsMultipleSelection = true
                segmentedSlider.showNumberOfSelected(show: true)
                
                if TipViews.currentStarStep == 2 || TipViews.currentCacheStep == 2 {
                    pressedSelectTip?()
                }
                
                selectButton.accessibilityHint = "Exit select mode"
            } else {
                segmentedSlider.showNumberOfSelected(show: false)
                deselectAllPhotos()
                resetToSelect()
                
                if TipViews.currentStarStep == 3 || TipViews.currentCacheStep == 3 {
                    TipViews.finishTutorial()
                }
            }
        }
    }
    func doneWithSelect() {
        selectButtonSelected = false
        showSelectionControls?(false)
        deselectAllPhotos()
        resetToSelect()
        
        selectButton.accessibilityHint = "Enter select mode"
    }
    
    func resetToSelect() {
        selectButton.title = NSLocalizedString("universal-select", comment: "")
        collectionView.allowsMultipleSelection = false
        segmentedSlider.showNumberOfSelected(show: false)
        updateActions?(.shouldStar)
        updateActions?(.shouldCache)
    }
    
    func updateSelectionLabel(to numberSelected: Int) {
        segmentedSlider.updateNumberOfSelected(to: numberSelected)
        updateNumberOfSelectedPhotos?(numberSelected)
    }
    func determineActions() {
        var starredCount = 0
        var notStarredCount = 0

        var cachedCount = 0
        var notCachedCount = 0

        for item in indexPathsSelected {
            if let itemToEdit = dataSource.itemIdentifier(for: item) {
                if let model = itemToEdit.editableModel, model.isHearted == true {
                    starredCount += 1
                } else {
                    notStarredCount += 1
                }

                if let model = itemToEdit.editableModel, model.isDeepSearched == true {
                    cachedCount += 1
                } else {
                    notCachedCount += 1
                }
            }
        }
        if notStarredCount >= starredCount {
            shouldStarSelection = true
            updateActions?(.shouldStar)
        } else {
            shouldStarSelection = false
            updateActions?(.shouldNotStar)
        }

        /// deselected all OR has one that's not cached
        if (cachedCount == 0 && notCachedCount == 0) || notCachedCount > 0 {
            shouldCacheSelection = true
            updateActions?(.shouldCache)
        } else {
            shouldCacheSelection = false
            updateActions?(.shouldNotCache)
        }
    }
    func deselectAllPhotos() {
        numberOfSelected = 0
        for indexP in indexPathsSelected {
            collectionView.deselectItem(at: indexP, animated: false)
            if let cell = collectionView.cellForItem(at: indexP) as? ImageCell {
                cell.highlightView.isHidden = true
                cell.selectionImageView.isHidden = true
            }
        }
        indexPathsSelected.removeAll()
    }
}
extension PhotosViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !refreshing {
            if selectButtonSelected == true {
                if !indexPathsSelected.contains(indexPath) {
                    indexPathsSelected.append(indexPath)
                    numberOfSelected += 1
                    if let cell = collectionView.cellForItem(at: indexPath) as? ImageCell {
                        cell.highlightView.isHidden = false
                        cell.selectionImageView.isHidden = false
                        cell.imageView.accessibilityTraits = [.image, .selected]
                    }
                }
                
            } else {
                collectionView.deselectItem(at: indexPath, animated: true)
                presentFromIndexPath(indexPath: indexPath)
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if selectButtonSelected == true {
            indexPathsSelected.remove(object: indexPath)
            numberOfSelected -= 1
            if let cell = collectionView.cellForItem(at: indexPath) as? ImageCell {
                cell.highlightView.isHidden = true
                cell.selectionImageView.isHidden = true
                cell.imageView.accessibilityTraits = .image
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        
        if selectButtonSelected {
            return true
        } else {
            return false
        }
    }

}

