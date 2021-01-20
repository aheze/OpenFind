//
//  PhotosVC+CollectionCoordinates.swift
//  Find
//
//  Created by Zheng on 1/9/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

/// get image and other data from collection view
extension PhotosViewController {
    
    //This function prevents the collectionView from accessing a deallocated cell. In the event
    //that the cell for the selectedIndexPath is nil, a default UIImageView is returned in its place
    func getImageViewFromCollectionViewCell(for selectedIndexPath: IndexPath) -> UIImageView {
        
        //Get the array of visible cells in the collectionView
        let visibleCells = collectionView.indexPathsForVisibleItems
        
        //If the current indexPath is not visible in the collectionView,
        //scroll the collectionView to the cell to prevent it from returning a nil value
        if !visibleCells.contains(selectedIndexPath) {
           
            //Scroll the collectionView to the current selectedIndexPath which is offscreen
            collectionView.scrollToItem(at: selectedIndexPath, at: .centeredVertically, animated: false)
            
            //Reload the items at the newly visible indexPaths
            collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
            
            let visiblePaths = collectionView.indexPathsForVisibleItems
            var changedPhotos = [FindPhoto]()
            for indexPath in visiblePaths {
                if let findPhoto = dataSource.itemIdentifier(for: indexPath) {
                    changedPhotos.append(findPhoto)
                }
            }
            applyModelSnapshot(changedItems: changedPhotos)
            collectionView.layoutIfNeeded()
            
            //Guard against nil values
            guard let guardedCell = (collectionView.cellForItem(at: selectedIndexPath) as? ImageCell) else {
                //Return a default UIImageView
                return UIImageView(frame: CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0))
            }
            //The PhotoCollectionViewCell was found in the collectionView, return the image
            return guardedCell.imageView
        }
        else {
            
            //Guard against nil return values
            guard let guardedCell = collectionView.cellForItem(at: selectedIndexPath) as? ImageCell else {
                //Return a default UIImageView
                return UIImageView(frame: CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0))
            }
            //The PhotoCollectionViewCell was found in the collectionView, return the image
            return guardedCell.imageView
        }
        
    }
    
    //This function prevents the collectionView from accessing a deallocated cell. In the
    //event that the cell for the selectedIndexPath is nil, a default CGRect is returned in its place
    func getFrameFromCollectionViewCell(for selectedIndexPath: IndexPath) -> CGRect {
        
        //Get the currently visible cells from the collectionView
        let visibleCells = collectionView.indexPathsForVisibleItems
        
        //If the current indexPath is not visible in the collectionView,
        //scroll the collectionView to the cell to prevent it from returning a nil value
        if !visibleCells.contains(selectedIndexPath) {
            
            //Scroll the collectionView to the cell that is currently offscreen
            collectionView.scrollToItem(at: selectedIndexPath, at: .centeredVertically, animated: false)
            
            //Reload the items at the newly visible indexPaths
//            collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
            
            let visiblePaths = collectionView.indexPathsForVisibleItems
            var changedPhotos = [FindPhoto]()
            for indexPath in visiblePaths {
                if let findPhoto = dataSource.itemIdentifier(for: indexPath) {
                    changedPhotos.append(findPhoto)
                }
            }
            applyModelSnapshot(changedItems: changedPhotos)
            collectionView.layoutIfNeeded()
            
            //Prevent the collectionView from returning a nil value
            guard let guardedCell = (collectionView.cellForItem(at: selectedIndexPath) as? ImageCell) else {
                return CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0)
            }
            
            return guardedCell.frame
        }
        //Otherwise the cell should be visible
        else {
            //Prevent the collectionView from returning a nil value
            guard let guardedCell = (collectionView.cellForItem(at: selectedIndexPath) as? ImageCell) else {
                return CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0)
            }
            //The cell was found successfully
            return guardedCell.frame
        }
    }
}
