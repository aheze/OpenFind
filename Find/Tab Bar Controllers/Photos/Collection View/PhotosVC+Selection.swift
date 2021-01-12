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
}

extension PhotosViewController {
    func selectPressed() {
        if allPhotosToDisplay.count == 0 {
//            showNoListsAlert()
            print("no phoos")
        } else {
            selectButtonSelected.toggle()
            showSelectionControls?(selectButtonSelected)
            if selectButtonSelected {
                selectButton.title = "Done"
                collectionView.allowsMultipleSelection = true
                segmentedSlider.showNumberOfSelected(show: true)
//                addButton.isEnabled = false
            } else {
                selectButton.title = "Select"
                collectionView.allowsMultipleSelection = false
                segmentedSlider.showNumberOfSelected(show: false)
//                deselectAllItems()
//                addButton.isEnabled = true
            }
        }
    }
    func updateSelectionLabel(to numberSelected: Int) {
        let text: String
        if numberSelected == 1 {
            text = "\(numberSelected) Photo Selected"
        } else {
            text = "\(numberSelected) Photos Selected"
        }

        segmentedSlider.numberOfSelectedLabel.text = text
    }
    func determineActions() {
        
        var starredCount = 0
        var notStarredCount = 0

        var cachedCount = 0
        var notCachedCount = 0

        for item in indexPathsSelected {
            if let itemToEdit = dataSource.itemIdentifier(for: item) {
                if let model = itemToEdit.model, model.isHearted == true {
                    starredCount += 1
                } else {
                    notStarredCount += 1
                }

                if let model = itemToEdit.model, model.isDeepSearched == true {
                    cachedCount += 1
                } else {
                    notCachedCount += 1
                }
            }
        }

        if notStarredCount >= starredCount {
            shouldStarSelection = true
            updateActions?(.shouldStar)
//            changeFloatDelegate?.changeFloat(to: "Unfill Heart")
        } else {
//            changeFloatDelegate?.changeFloat(to: "Fill Heart")
            shouldStarSelection = false
            updateActions?(.shouldNotStar)
        }

        if notCachedCount >= 1 {
            shouldCacheSelection = true
            updateActions?(.shouldCache)
//            changeFloatDelegate?.changeFloat(to: "NotCached")
        } else {
            shouldCacheSelection = false
            updateActions?(.shouldNotCache)
//            changeFloatDelegate?.changeFloat(to: "Cached")
        }
    }
}
extension PhotosViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectButtonSelected == true {
            if !indexPathsSelected.contains(indexPath) {
                indexPathsSelected.append(indexPath)
                numberOfSelected += 1
                if let cell = collectionView.cellForItem(at: indexPath) as? ImageCell {
                    cell.highlightView.isHidden = false
                    cell.selectionImageView.isHidden = false
                }
            }
            
        } else {
            collectionView.deselectItem(at: indexPath, animated: true)
            presentFromIndexPath(indexPath: indexPath)
        }
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if selectButtonSelected == true {
            indexPathsSelected.remove(object: indexPath)
            numberOfSelected -= 1
            if let cell = collectionView.cellForItem(at: indexPath) as? ImageCell {
                cell.highlightView.isHidden = true
                cell.selectionImageView.isHidden = true
            }
        }
    }
    
}

