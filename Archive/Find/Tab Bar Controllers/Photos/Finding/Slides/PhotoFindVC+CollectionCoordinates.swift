//
//  PhotoFindVC+CollectionCoordinates.swift
//  Find
//
//  Created by Zheng on 1/17/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotoFindViewController {
    func referenceImageView(for zoomAnimator: ZoomAnimator) -> UIImageView? {
        guard let selectedIndexPath = selectedIndexPath else { return nil }
        // Get a guarded reference to the cell's UIImageView
        let referenceImageView = getImageViewFromCollectionViewCell(for: selectedIndexPath)
        
        return referenceImageView
    }
    
    func referenceImageViewFrameInTransitioningView(for zoomAnimator: ZoomAnimator) -> CGRect? {
        guard let selectedIndexPath = selectedIndexPath else { return nil }
        
        view.layoutIfNeeded()
        tableView.layoutIfNeeded()
        
        // Get a guarded reference to the cell's frame
        let unconvertedFrame = getFrameFromCollectionViewCell(for: selectedIndexPath, presenting: zoomAnimator.isPresenting)
        
        var cellFrame = tableView.convert(unconvertedFrame, to: view)
        
        if cellFrame.minY < tableView.contentInset.top {
            return CGRect(x: cellFrame.minX, y: tableView.contentInset.top, width: cellFrame.width, height: cellFrame.height - (tableView.contentInset.top - cellFrame.minY))
        }
        
        /// Don't convert frame to nil
        
        cellFrame.origin.y += view.frame.origin.y
        
        return cellFrame
    }
    
    // This function prevents the collectionView from accessing a deallocated cell. In the event
    // that the cell for the selectedIndexPath is nil, a default UIImageView is returned in its place
    func getImageViewFromCollectionViewCell(for selectedIndexPath: IndexPath) -> UIImageView {
        // Get the array of visible cells in the collectionView
        if let visibleCells = tableView.indexPathsForVisibleRows {
            // If the current indexPath is not visible in the collectionView,
            // scroll the collectionView to the cell to prevent it from returning a nil value
            if !visibleCells.contains(selectedIndexPath) {
                // Scroll the collectionView to the current selectedIndexPath which is offscreen
                tableView.scrollToRow(at: selectedIndexPath, at: .middle, animated: false)
                
                // Reload the items at the newly visible indexPaths
                tableView.reloadRows(at: visibleCells, with: .none)
                tableView.layoutIfNeeded()
                
                guard let guardedCell = (tableView.cellForRow(at: selectedIndexPath) as? HistoryFindCell) else {
                    return UIImageView(frame: CGRect(x: screenBounds.midX, y: screenBounds.midY, width: 100.0, height: 100.0))
                }
                // The PhotoCollectionViewCell was found in the collectionView, return the image
                return guardedCell.photoImageView
            } else {
                guard let guardedCell = (tableView.cellForRow(at: selectedIndexPath) as? HistoryFindCell) else {
                    return UIImageView(frame: CGRect(x: screenBounds.midX, y: screenBounds.midY, width: 100.0, height: 100.0))
                }
                // The PhotoCollectionViewCell was found in the collectionView, return the image
                return guardedCell.photoImageView
            }
        } else {
            tableView.scrollToRow(at: selectedIndexPath, at: .middle, animated: false)
            
            if let newlyVisibleCells = tableView?.indexPathsForVisibleRows {
                tableView.reloadRows(at: newlyVisibleCells, with: .none)
            }
            tableView.layoutIfNeeded()
            
            guard let guardedCell = (tableView.cellForRow(at: selectedIndexPath) as? HistoryFindCell) else {
                return UIImageView(frame: CGRect(x: screenBounds.midX, y: screenBounds.midY, width: 100.0, height: 100.0))
            }
            
            return guardedCell.photoImageView
        }
    }
    
    // This function prevents the collectionView from accessing a deallocated cell. In the
    // event that the cell for the selectedIndexPath is nil, a default CGRect is returned in its place
    func getFrameFromCollectionViewCell(for selectedIndexPath: IndexPath, presenting: Bool) -> CGRect {
        // Get the currently visible cells from the collectionView
        if let visibleCells = tableView.indexPathsForVisibleRows {
            // If the current indexPath is not visible in the collectionView,
            // scroll the collectionView to the cell to prevent it from returning a nil value
            if !visibleCells.contains(selectedIndexPath) {
                // Scroll the collectionView to the cell that is currently offscreen
                //            self.tableView.scrollToItem(at: self.selectedIndexPath, at: .centeredVertically, animated: false)
                tableView.scrollToRow(at: selectedIndexPath, at: .middle, animated: false)
                // Reload the items at the newly visible indexPaths
                //            self.tableView.reloadItems(at: visibleCells)
                if let newlyVisibleCells = tableView?.indexPathsForVisibleRows {
                    tableView.reloadRows(at: newlyVisibleCells, with: .none)
                }
                
                tableView.layoutIfNeeded()
                
                // Prevent the collectionView from returning a nil value
                guard let guardedCell = (tableView.cellForRow(at: selectedIndexPath) as? HistoryFindCell) else {
                    return CGRect(x: screenBounds.midX, y: screenBounds.midY, width: 100.0, height: 100.0)
                }
                
                var cellFrame = guardedCell.frame
                cellFrame.origin.x += 16
                cellFrame.origin.y += 6
                cellFrame.size.width = 100
                cellFrame.size.height -= 12
                
                return cellFrame
            }
            // Otherwise the cell should be visible
            else {
                // Prevent the collectionView from returning a nil value
                guard let guardedCell = (tableView.cellForRow(at: selectedIndexPath) as? HistoryFindCell) else {
                    return CGRect(x: screenBounds.midX, y: screenBounds.midY, width: 100.0, height: 100.0)
                }
                // The cell was found successfully
                //                return guardedCell.frame
                var cellFrame = guardedCell.frame
                cellFrame.origin.x += 16
                cellFrame.origin.y += 6
                cellFrame.size.width = 100
                cellFrame.size.height -= 12
                
                return cellFrame
            }
        } else {
            tableView.scrollToRow(at: selectedIndexPath, at: .middle, animated: false)
            // Reload the items at the newly visible indexPaths
            //            self.tableView.reloadItems(at: visibleCells)
            if let newlyVisibleCells = tableView?.indexPathsForVisibleRows {
                tableView.reloadRows(at: newlyVisibleCells, with: .none)
            }
            tableView.layoutIfNeeded()
            
            // Prevent the collectionView from returning a nil value
            guard let guardedCell = (tableView.cellForRow(at: selectedIndexPath) as? HistoryFindCell) else {
                return CGRect(x: screenBounds.midX, y: screenBounds.midY, width: 100.0, height: 100.0)
            }
            
            var cellFrame = guardedCell.frame
            cellFrame.origin.x += 16
            cellFrame.origin.y += 6
            cellFrame.size.width = 100
            cellFrame.size.height -= 12
            
            return cellFrame
        }
    }
}
