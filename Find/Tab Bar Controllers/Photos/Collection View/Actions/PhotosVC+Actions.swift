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
                
                if let model = findPhoto.editableModel {
                    cell.cacheImageView.alpha = model.isDeepSearched ? 1 : 0
                    cell.starImageView.alpha = model.isHearted ? 1 : 0
                    cell.shadowImageView.alpha = (model.isDeepSearched || model.isHearted ) ? 1 : 0
                } else {
                    cell.cacheImageView.alpha = 0
                    cell.starImageView.alpha = 0
                    cell.shadowImageView.alpha = 0
                }
            }
        }
    }
}
