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
//                    editablePhoto.isDeepSearched = photo.isDeepSearched
//                    editablePhoto.isHearted = photo.isHearted
//
//                    var photoContents = [EditableSingleHistoryContent]()
//                    for content in photo.contents {
//                        let editableContent = EditableSingleHistoryContent()
//                        editableContent.text = content.text
//                        editableContent.x = CGFloat(content.x)
//                        editableContent.y = CGFloat(content.y)
//                        editableContent.width = CGFloat(content.width)
//                        editableContent.height = CGFloat(content.height)
//                        photoContents.append(editableContent)
//                    }
//
//                    editablePhoto.contents = photoContents
                    editablePhotos.append(editablePhoto)
                }
                
                
                
                viewController.editablePhotosToMigrate = editablePhotos
                viewController.folderURL = folderURL
                self.present(viewController, animated: true)
            }
        }
    }
}
  
