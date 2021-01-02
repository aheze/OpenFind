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
    func showMigrationView(photosToMigrate: [URL]) {
        
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
                viewController.photoURLs = photosToMigrate
                self.present(viewController, animated: true)
            }
        }
    }
}
  
