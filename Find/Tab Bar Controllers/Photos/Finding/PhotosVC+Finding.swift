//
//  PhotosVC+Finding.swift
//  Find
//
//  Created by Zheng on 1/15/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotosViewController {
    func setupFinding() {
        collapseButton.layer.cornerRadius = 16
        collapseButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        collapseButton.alpha = 0
    }
    func findPressed() {

        if indexPathsSelected.isEmpty {
            switchToFind?(photoFilterState, allPhotosToDisplay, true, hasChangedFromBefore)
        } else {
            var findPhotos = [FindPhoto]()
            for indexPath in indexPathsSelected {
                if let findPhoto = dataSource.itemIdentifier(for: indexPath) {
                    findPhotos.append(findPhoto)
                }
            }
            switchToFind?(photoFilterState, findPhotos, false, hasChangedFromBefore)
        }
        
        if selectButtonSelected {
            showSelectionControls?(false)
        }
        
        hasChangedFromBefore = false
    }
}
