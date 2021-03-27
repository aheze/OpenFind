//
//  PhotosVC+Actions.swift
//  Find
//
//  Created by Zheng on 1/12/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import RealmSwift

extension PhotosViewController {
    func reloadPaths(changedPaths: [IndexPath]) {
        for indexPath in changedPaths {
            if let cell = collectionView.cellForItem(at: indexPath) as? ImageCell, let findPhoto = dataSource.itemIdentifier(for: indexPath) {
                
                var accessibilityLabel = "Photo."
                
                if let dateCreated = findPhoto.asset.creationDate {
                    let dateDistance = dateCreated.distance(from: Date(), only: .year)
                    print("date dist: \(dateDistance)")
                    
                    let dateFormatter = DateFormatter()
                    
                    if dateDistance == 0 {
                        dateFormatter.dateFormat = "MMMM d' at 'h:mm a"
                    } else { /// -1 if older by a year
                        dateFormatter.dateFormat = "MMMM d, yyyy', at 'h:mm a"
                    }
                    let dateCreatedString = dateFormatter.string(from: dateCreated)
                    accessibilityLabel = "\(dateCreatedString)."
                }
                
                if let model = findPhoto.editableModel {
                    cell.cacheImageView.alpha = model.isDeepSearched ? 1 : 0
                    cell.starImageView.alpha = model.isHearted ? 1 : 0
                    cell.shadowImageView.alpha = (model.isDeepSearched || model.isHearted ) ? 1 : 0
                    
                    if model.isHearted {
                        accessibilityLabel.append(" Starred")
                        if model.isDeepSearched {
                            accessibilityLabel.append(" and Cached.")
                        } else {
                            accessibilityLabel.append(".")
                        }
                    } else if model.isDeepSearched {
                        accessibilityLabel.append(" Cached.")
                    }
                } else {
                    cell.cacheImageView.alpha = 0
                    cell.starImageView.alpha = 0
                    cell.shadowImageView.alpha = 0
                }
                
                cell.accessibilityLabel = accessibilityLabel
            }
        }
    }
}
