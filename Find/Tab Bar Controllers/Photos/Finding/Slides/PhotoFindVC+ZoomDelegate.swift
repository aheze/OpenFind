//
//  PhotoFindVC+ZoomDelegate.swift
//  Find
//
//  Created by Zheng on 1/17/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

/// When the slides pages left or right
extension PhotoFindViewController: PhotoSlidesUpdatedIndex {
    
    func indexUpdated(to newIndex: Int) {
        let currentPhoto = resultPhotos[newIndex]
        let indexPath = IndexPath(row: newIndex, section: 0)
        
        if let selectedIndexPath = selectedIndexPath {
            if let cell = tableView.cellForRow(at: selectedIndexPath) as? HistoryFindCell { /// old index
                if let model = currentPhoto.findPhoto.editableModel {
                    if model.isHearted || model.isDeepSearched  {
                        cell.shadowImageView.alpha = 1
                    } else {
                        cell.shadowImageView.alpha = 0
                    }
                    if model.isHearted {
                        cell.starImageView.alpha = 1
                    } else {
                        cell.starImageView.alpha = 0
                    }
                    if model.isDeepSearched {
                        cell.cacheImageView.alpha = 1
                    } else {
                        cell.cacheImageView.alpha = 0
                    }
                }
            }
            
            if let cell = tableView.cellForRow(at: indexPath) as? HistoryFindCell { /// new index
                if let model = currentPhoto.findPhoto.editableModel {
                    if model.isHearted || model.isDeepSearched  {
                        cell.shadowImageView.alpha = 0
                    }
                    if model.isHearted {
                        cell.starImageView.alpha = 0
                    }
                    if model.isDeepSearched {
                        cell.cacheImageView.alpha = 0
                    }
                }
            }
        }
        
        selectedIndexPath = indexPath
        tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
        
    }
}

extension PhotoFindViewController: ZoomAnimatorDelegate {
    
    func transitionWillStartWith(zoomAnimator: ZoomAnimator) {
        print("starting!")
        zoomAnimator.cameFromFind = true
    }
    
    func transitionDidEndWith(zoomAnimator: ZoomAnimator) {
        
        guard let selectedIndexPath = selectedIndexPath else { return }
        
        let cell = tableView.cellForRow(at: selectedIndexPath) as! HistoryFindCell
        if zoomAnimator.isPresenting == false && zoomAnimator.finishedDismissing == true {
            
            changePresentationMode(presentingSlides: false)
            if let model = resultPhotos[selectedIndexPath.row].findPhoto.editableModel {
                UIView.animate(withDuration: 0.2, animations: {
                    if model.isHearted || model.isDeepSearched  {
                        cell.shadowImageView.alpha = 1
                    }
                    if model.isHearted {
                        cell.starImageView.alpha = 1
                    }
                    if model.isDeepSearched {
                        cell.cacheImageView.alpha = 1
                    }
                })
            }
        }
        
        
        let cellFrame = self.tableView.convert(cell.frame, to: self.view)
        
        if cellFrame.minY < self.tableView.contentInset.top {
            self.tableView.scrollToRow(at: selectedIndexPath, at: .top, animated: false)
        } else if cellFrame.maxY > self.view.frame.height - self.tableView.contentInset.bottom {
            self.tableView.scrollToRow(at: selectedIndexPath, at: .bottom, animated: false)
        }
    }
}
