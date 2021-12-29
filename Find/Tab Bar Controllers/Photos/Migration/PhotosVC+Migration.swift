//
//  PhotosVC+Migration.swift
//  Find
//
//  Created by Zheng on 1/1/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import SnapKit

extension PhotosViewController {
    func showMigrationView(photosToMigrate: [HistoryModel], folderURL: URL) {
        
        collectionView.alpha = 0
        
        let scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor.systemBackground
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let migrationView = PhotosMigrationView()
        scrollView.addSubview(migrationView)
        migrationView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(500)
        }
        
        migrationView.movePressed = { [weak self] in
            guard let self = self else { return }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let viewController = storyboard.instantiateViewController(withIdentifier: "PhotosMigrationController") as? PhotosMigrationController {
                
                var editablePhotos = [EditableHistoryModel]()
                for photo in photosToMigrate {
                    let editablePhoto = EditableHistoryModel()
                    editablePhoto.dateCreated = photo.dateCreated
                    editablePhoto.filePath = photo.filePath
                    editablePhoto.isDeepSearched = photo.isDeepSearched
                    editablePhoto.isHearted = photo.isHearted
                    editablePhotos.append(editablePhoto)
                }
                
                viewController.folderURL = folderURL
                viewController.editablePhotosToMigrate = editablePhotos /// editable so can access on background thread
                viewController.realPhotos = photosToMigrate /// modify the real photo's assetIdenfier later
                
                viewController.completed = { [weak self] in
                    guard let self = self else { return }

                    
//                    collectionView.
//                    applySnapshot(animatingDifferences: false)
                    
                    self.fetchAssets()
                    scrollView.isUserInteractionEnabled = false
                    UIView.animate(withDuration: 0.5, animations: {
                        scrollView.alpha = 0
                        scrollView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                        self.collectionView.alpha = 1
                    }) { _ in
                        scrollView.removeFromSuperview()
                    }
                    
                }
                self.present(viewController, animated: true)
            }
        }
    }
}
  
