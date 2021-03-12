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
        //Get a guarded reference to the cell's UIImageView
        let referenceImageView = getImageViewFromCollectionViewCell(for: selectedIndexPath)
        
        return referenceImageView
    }
    
    func referenceImageViewFrameInTransitioningView(for zoomAnimator: ZoomAnimator) -> CGRect? {
        guard let selectedIndexPath = selectedIndexPath else { return nil }
        
        self.view.layoutIfNeeded()
        self.tableView.layoutIfNeeded()
        
        //Get a guarded reference to the cell's frame
        let unconvertedFrame = getFrameFromCollectionViewCell(for: selectedIndexPath, presenting: zoomAnimator.isPresenting)
        
        var cellFrame = self.tableView.convert(unconvertedFrame, to: self.view)
        
        if cellFrame.minY < self.tableView.contentInset.top {
            return CGRect(x: cellFrame.minX, y: self.tableView.contentInset.top, width: cellFrame.width, height: cellFrame.height - (self.tableView.contentInset.top - cellFrame.minY))
        }
        let superCellFrame = self.tableView.convert(unconvertedFrame, to: nil)
        let cellYDiff = superCellFrame.origin.y - cellFrame.origin.y
        let cellXDiff = superCellFrame.origin.x - cellFrame.origin.x
        
        cellFrame.origin.y += cellYDiff
        cellFrame.origin.x += cellXDiff
        return cellFrame
    }
    
    //This function prevents the collectionView from accessing a deallocated cell. In the event
    //that the cell for the selectedIndexPath is nil, a default UIImageView is returned in its place
    func getImageViewFromCollectionViewCell(for selectedIndexPath: IndexPath) -> UIImageView {
        //Get the array of visible cells in the collectionView
        if let visibleCells = self.tableView.indexPathsForVisibleRows {
            
            //If the current indexPath is not visible in the collectionView,
            //scroll the collectionView to the cell to prevent it from returning a nil value
            if !visibleCells.contains(selectedIndexPath) {
                
                //Scroll the collectionView to the current selectedIndexPath which is offscreen
                self.tableView.scrollToRow(at: selectedIndexPath, at: .middle, animated: false)
                
                //Reload the items at the newly visible indexPaths
                self.tableView.reloadRows(at: visibleCells, with: .none)
                self.tableView.layoutIfNeeded()
                
                guard let guardedCell = (self.tableView.cellForRow(at: selectedIndexPath) as? HistoryFindCell) else {
                    return UIImageView(frame: CGRect(x: screenBounds.midX, y: screenBounds.midY, width: 100.0, height: 100.0))
                }
                //The PhotoCollectionViewCell was found in the collectionView, return the image
                return guardedCell.photoImageView
            }
            else {
                
                
                guard let guardedCell = (self.tableView.cellForRow(at: selectedIndexPath) as? HistoryFindCell) else {
                    return UIImageView(frame: CGRect(x: screenBounds.midX, y: screenBounds.midY, width: 100.0, height: 100.0))
                }
                //The PhotoCollectionViewCell was found in the collectionView, return the image
                return guardedCell.photoImageView
            }
        } else {
            self.tableView.scrollToRow(at: selectedIndexPath, at: .middle, animated: false)
            
            if let newlyVisibleCells = self.tableView?.indexPathsForVisibleRows {
                self.tableView.reloadRows(at: newlyVisibleCells, with: .none)
            }
            self.tableView.layoutIfNeeded()
            
            guard let guardedCell = (self.tableView.cellForRow(at: selectedIndexPath) as? HistoryFindCell) else {
                return UIImageView(frame: CGRect(x: screenBounds.midX, y: screenBounds.midY, width: 100.0, height: 100.0))
            }
            
            return guardedCell.photoImageView
        }
        
    }
    
    //This function prevents the collectionView from accessing a deallocated cell. In the
    //event that the cell for the selectedIndexPath is nil, a default CGRect is returned in its place
    func getFrameFromCollectionViewCell(for selectedIndexPath: IndexPath, presenting: Bool) -> CGRect {

        //Get the currently visible cells from the collectionView
        if let visibleCells = self.tableView.indexPathsForVisibleRows {
            
            
            //If the current indexPath is not visible in the collectionView,
            //scroll the collectionView to the cell to prevent it from returning a nil value
            if !visibleCells.contains(selectedIndexPath) {
                
                //Scroll the collectionView to the cell that is currently offscreen
                //            self.tableView.scrollToItem(at: self.selectedIndexPath, at: .centeredVertically, animated: false)
                self.tableView.scrollToRow(at: selectedIndexPath, at: .middle, animated: false)
                //Reload the items at the newly visible indexPaths
                //            self.tableView.reloadItems(at: visibleCells)
                if let newlyVisibleCells = self.tableView?.indexPathsForVisibleRows {
                    self.tableView.reloadRows(at: newlyVisibleCells, with: .none)
                }
                
                self.tableView.layoutIfNeeded()
                
                //Prevent the collectionView from returning a nil value
                guard let guardedCell = (self.tableView.cellForRow(at: selectedIndexPath) as? HistoryFindCell) else {
                    return CGRect(x: screenBounds.midX, y: screenBounds.midY + addTopHeight(presenting: presenting), width: 100.0, height: 100.0)
                }
                
                var cellFrame = guardedCell.frame
                cellFrame.origin.x += 16
                cellFrame.origin.y += 6 + addTopHeight(presenting: presenting)
                cellFrame.size.width = 100
                cellFrame.size.height -= 12
                
                return cellFrame
            }
            //Otherwise the cell should be visible
            else {
                //Prevent the collectionView from returning a nil value
                guard let guardedCell = (self.tableView.cellForRow(at: selectedIndexPath) as? HistoryFindCell) else {
                    return CGRect(x: screenBounds.midX, y: screenBounds.midY + addTopHeight(presenting: presenting), width: 100.0, height: 100.0)
                }
                //The cell was found successfully
                //                return guardedCell.frame
                var cellFrame = guardedCell.frame
                cellFrame.origin.x += 16
                cellFrame.origin.y += 6 + addTopHeight(presenting: presenting)
                cellFrame.size.width = 100
                cellFrame.size.height -= 12
                
                return cellFrame
            }
        } else {
            self.tableView.scrollToRow(at: selectedIndexPath, at: .middle, animated: false)
            //Reload the items at the newly visible indexPaths
            //            self.tableView.reloadItems(at: visibleCells)
            if let newlyVisibleCells = self.tableView?.indexPathsForVisibleRows {
                self.tableView.reloadRows(at: newlyVisibleCells, with: .none)
            }
            self.tableView.layoutIfNeeded()
            
            //Prevent the collectionView from returning a nil value
            guard let guardedCell = (self.tableView.cellForRow(at: selectedIndexPath) as? HistoryFindCell) else {
                return CGRect(x: screenBounds.midX, y: screenBounds.midY + addTopHeight(presenting: presenting), width: 100.0, height: 100.0)
            }
            
            //            return guardedCell.frame
            var cellFrame = guardedCell.frame
            cellFrame.origin.x += 16
            cellFrame.origin.y += 6 + addTopHeight(presenting: presenting)
            cellFrame.size.width = 100
            cellFrame.size.height -= 12
            
            return cellFrame
        }
    }
    func addTopHeight(presenting: Bool) -> CGFloat {
        print("Add top height! tabl off:\(tableView.contentOffset.y)")
        
        if presenting {
            return 0
        } else {
            
            let topInset = self.view.frame.origin.y + tableView.frame.origin.y - tableView.contentOffset.y
            print(topInset)
            
            return topInset
        }
    }
}

